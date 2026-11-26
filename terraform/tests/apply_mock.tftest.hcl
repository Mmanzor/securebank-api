mock_provider "aws" {}

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
