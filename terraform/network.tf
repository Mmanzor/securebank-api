resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "edge" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false
}

resource "aws_default_security_group" "closed" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app"
  description = "HTTPS y administracion desde la red autorizada"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Administracion interna"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [local.admin_cidr]
  }

  ingress {
    description = "HTTPS interno"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Comunicacion interna"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "PostgreSQL solo desde el grupo de aplicaciones"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL desde las aplicaciones"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.app.id]
  }
}

resource "aws_lb" "frontend" {
  name                       = "${var.name}-internal"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.app.id]
  subnets                    = [aws_subnet.edge.id, aws_subnet.private.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  enable_http2               = true
  desync_mitigation_mode     = "strictest"

  access_logs {
    bucket  = local.collection_bucket.id
    prefix  = "balancer"
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.logs]
}
