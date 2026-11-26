resource "aws_cloudwatch_log_group" "flow" {
  name              = "${local.log_group_prefix}/flow"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.data.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}-api"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.data.arn
}

resource "aws_iam_role" "flow" {
  name = "${var.name}-flow-logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Condition = { StringEquals = { "aws:SourceAccount" = var.account_id } }
    }]
  })
}

resource "aws_iam_role_policy" "flow" {
  name = "${var.name}-flow-logs"
  role = aws_iam_role.flow.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
      Resource = "${aws_cloudwatch_log_group.flow.arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc" {
  count                = local.enable_logging ? 1 : 0
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.flow.arn
  log_destination      = aws_cloudwatch_log_group.flow.arn
  log_destination_type = "cloud-watch-logs"
  depends_on           = [aws_iam_role_policy.flow]
}

resource "aws_cloudtrail" "main" {
  name                          = local.cloudtrail_name
  s3_bucket_name                = local.collection_bucket.id
  enable_logging                = local.enable_logging
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.data.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.trail.arn
  sns_topic_name                = aws_sns_topic.trail.arn

  depends_on = [aws_s3_bucket_policy.logs, aws_iam_role_policy.trail]
}

resource "aws_cloudwatch_log_group" "trail" {
  name              = "${local.log_group_prefix}/trail"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.data.arn
}

resource "aws_sns_topic" "trail" {
  name              = "${var.name}-trail"
  kms_master_key_id = aws_kms_key.data.arn
}

resource "aws_iam_role" "trail" {
  name = "${var.name}-trail"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "cloudtrail.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "trail" {
  name = "${var.name}-trail"
  role = aws_iam_role.trail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.trail.arn}:*"
    }]
  })
}
