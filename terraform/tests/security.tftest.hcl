mock_provider "aws" {}

variables {
  account_id = "123456789012"
  ami_id     = "ami-0123456789abcdef0"
}

run "plan_lab" {
  command = plan

  assert {
    condition     = aws_db_instance.postgres.storage_encrypted && !aws_db_instance.postgres.publicly_accessible
    error_message = "PostgreSQL debe permanecer privado y cifrado."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.block_public_policy && aws_s3_bucket_public_access_block.logs.block_public_policy
    error_message = "Todos los buckets deben bloquear acceso público."
  }

  assert {
    condition     = length(aws_flow_log.vpc) == 1 && aws_cloudtrail.main.enable_logging
    error_message = "VPC Flow Logs y CloudTrail deben estar habilitados."
  }

  assert {
    condition = alltrue([
      for instance in aws_instance.app : !instance.associate_public_ip_address &&
      instance.metadata_options[0].http_tokens == "required"
    ])
    error_message = "Las instancias deben ser privadas y exigir IMDSv2."
  }
}
