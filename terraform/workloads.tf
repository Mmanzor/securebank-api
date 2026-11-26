resource "aws_instance" "app" {
  for_each = {
    web    = aws_subnet.edge.id
    worker = aws_subnet.private.id
  }

  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = each.value
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.app.id]
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.app.name
  ebs_optimized               = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.data.arn
    volume_type = "gp3"
  }

  tags = { Name = "${var.name}-${each.key}" }
}

resource "aws_iam_role" "workload" {
  name = "${var.name}-lambda"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "workload" {
  name = "${var.name}-lambda"
  role = aws_iam_role.workload.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = local.workload_actions
        Resource = local.workload_resources
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      }
    ]
  })
}

resource "aws_iam_user" "ci" {
  name = "${var.name}-ci-reference"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.js"
  output_path = "${path.module}/.terraform/lambda.zip"
}

resource "aws_lambda_function" "api" {
  function_name                  = "${var.name}-api"
  role                           = aws_iam_role.workload.arn
  handler                        = "handler.health"
  runtime                        = "nodejs22.x"
  filename                       = data.archive_file.lambda.output_path
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  reserved_concurrent_executions = 2
  kms_key_arn                    = aws_kms_key.data.arn
  timeout                        = 5

  tracing_config {
    mode = "PassThrough"
  }

  depends_on = [aws_iam_role_policy.workload, aws_cloudwatch_log_group.lambda]
}

resource "aws_ecr_repository" "api" {
  name                 = "${var.name}-api"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.data.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "app" {
  name = "${var.name}-ec2"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name}-ec2"
  role = aws_iam_role.app.name
}
