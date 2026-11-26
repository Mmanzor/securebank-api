resource "aws_s3_bucket" "backups" {
  bucket = "${var.name}-${var.account_id}-backups"
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = local.block_public_access
  block_public_policy     = local.block_public_access
  ignore_public_acls      = local.block_public_access
  restrict_public_buckets = local.block_public_access
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "retain-and-clean"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 180
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.name}-${var.account_id}-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = local.block_public_access
  block_public_policy     = local.block_public_access
  ignore_public_acls      = local.block_public_access
  restrict_public_buckets = local.block_public_access
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "retain-and-clean"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 180
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_logging" "backups" {
  bucket        = aws_s3_bucket.backups.id
  target_bucket = local.collection_bucket.id
  target_prefix = "s3-backups/"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = local.collection_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = local.collection_bucket.arn
        Condition = { StringEquals = { "aws:SourceArn" = local.cloudtrail_arn } }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${local.collection_bucket.arn}/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = local.cloudtrail_arn
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "logdelivery.elasticloadbalancing.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${local.collection_bucket.arn}/balancer/AWSLogs/${var.account_id}/*"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${local.collection_bucket.arn}/s3-backups/*"
        Condition = {
          ArnLike      = { "aws:SourceArn" = aws_s3_bucket.backups.arn }
          StringEquals = { "aws:SourceAccount" = var.account_id }
        }
      }
    ]
  })
}

resource "aws_kms_key" "data" {
  description             = "Cifrado de datos y registros de SecureBank"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = local.account_principal }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = ["kms:GenerateDataKey*", "kms:DescribeKey"]
        Resource  = "*"
        Condition = { StringEquals = { "aws:SourceArn" = local.cloudtrail_arn } }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "logs.${var.region}.amazonaws.com" }
        Action    = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
        Resource  = "*"
        Condition = {
          ArnLike = { "kms:EncryptionContext:aws:logs:arn" = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.log_group_prefix}/*", "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.name}-api"] }
        }
      }
    ]
  })
}

resource "aws_db_subnet_group" "private" {
  name       = "${var.name}-db"
  subnet_ids = [aws_subnet.edge.id, aws_subnet.private.id]
}

resource "aws_db_instance" "postgres" {
  identifier                          = "${var.name}-db"
  engine                              = "postgres"
  engine_version                      = "16"
  instance_class                      = "db.t4g.micro"
  allocated_storage                   = 20
  max_allocated_storage               = 100
  storage_type                        = "gp3"
  username                            = "securebank"
  manage_master_user_password         = true
  db_subnet_group_name                = aws_db_subnet_group.private.name
  vpc_security_group_ids              = [aws_security_group.db.id]
  publicly_accessible                 = false
  storage_encrypted                   = local.encrypt_rds
  kms_key_id                          = local.encrypt_rds ? aws_kms_key.data.arn : null
  backup_retention_period             = 7
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  deletion_protection                 = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "${var.name}-db-final"
  copy_tags_to_snapshot               = true
  multi_az                            = true
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = aws_kms_key.data.arn
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring.arn
  parameter_group_name                = aws_db_parameter_group.postgres.name
}

resource "aws_dynamodb_table" "transactions" {
  name         = "${var.name}-transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.data.arn
  }

  deletion_protection_enabled = true
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_subnet.private.availability_zone
  size              = 20
  type              = "gp3"
  encrypted         = true
  kms_key_id        = aws_kms_key.data.arn
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.name}-postgres16"
  family = "postgres16"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.name}-rds-monitoring"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "monitoring.rds.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
