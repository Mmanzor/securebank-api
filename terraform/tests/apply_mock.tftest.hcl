mock_provider "aws" {
  mock_resource "aws_kms_key" {
    defaults = { arn = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-4000-8000-000000000001" }
  }

  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/securebank-s11-mock" }
  }

  mock_resource "aws_cloudwatch_log_group" {
    defaults = { arn = "arn:aws:logs:us-east-1:123456789012:log-group:/securebank/securebank-s11/mock" }
  }

  mock_resource "aws_sns_topic" {
    defaults = { arn = "arn:aws:sns:us-east-1:123456789012:securebank-s11-mock" }
  }
}

variables {
  account_id = "123456789012"
  ami_id     = "ami-0123456789abcdef0"
}

run "apply_lab" {
  command = apply

  assert {
    condition     = aws_lb.frontend.internal && aws_ecr_repository.api.image_tag_mutability == "IMMUTABLE"
    error_message = "El balanceador debe ser interno y el registro debe usar etiquetas inmutables."
  }

  assert {
    condition     = aws_kms_key.data.enable_key_rotation && aws_dynamodb_table.transactions.server_side_encryption[0].enabled
    error_message = "La clave debe rotar y los datos de DynamoDB deben cifrarse."
  }
}
