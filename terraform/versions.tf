terraform {
  required_version = "~> 1.17.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = { Project = "SecureBank", Environment = "lab-s11" }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type        = string
  description = "ID de la cuenta del entorno de laboratorio."
}

variable "name" {
  type    = string
  default = "securebank-s11"
}

variable "ami_id" {
  type        = string
  description = "AMI aprobada para la región y arquitectura de las instancias."
}

locals {
  block_public_access = true
  encrypt_rds         = true
  enable_logging      = true
  admin_cidr          = "10.20.0.0/16"
  workload_actions    = ["s3:GetObject"]
  workload_resources  = ["${aws_s3_bucket.backups.arn}/health/*"]
  collection_bucket   = aws_s3_bucket.logs
  log_group_prefix    = "/securebank/${var.name}"
  account_principal   = "arn:aws:iam::${var.account_id}:root"
  cloudtrail_name     = "${var.name}-trail"
  cloudtrail_arn      = "arn:aws:cloudtrail:${var.region}:${var.account_id}:trail/${local.cloudtrail_name}"
}
