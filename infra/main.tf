# ---------------------------------------------------------------------------
# main.tf — Core infrastructure: VPC, EC2, Security Groups
# 
# RISK ASSESSMENT (for your PM hat):
# Risk                     | Likelihood | Impact | Mitigation
# -------------------------|-----------|--------|--------------------------------------
# S3 bucket made public    | Medium    | High   | Pipeline tfsec check blocks it
# SSH open to world        | High      | High   | Pipeline Checkov check blocks it
# EC2 costs if left running| Medium    | Low    | Terraform destroy + budget alert
# State file exposure      | Low       | High   | S3 bucket block-public-access enabled
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5"

  # Backend configured dynamically in CI/CD pipeline
  # Pipeline passes bucket, key, region via -backend-config at init time
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# VPC — Isolated network for the demo
# Using the default VPC for simplicity. In production: create a custom VPC.
# ---------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---------------------------------------------------------------------------
# Security Group — Inbound rules for HTTP (app access)
# 
# NOTE: SSH rule uses var.allowed_ssh_cidr which defaults to 0.0.0.0/0.
# This WILL be caught by tfsec/Checkov in the pipeline as a critical finding.
# That's intentional — it demonstrates the security gate working.
# ---------------------------------------------------------------------------
resource "aws_security_group" "demo_sg" {
  name        = "${var.project_name}-sg-${var.environment}"
  description = "Security group for cloud-secure-cicd demo"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name        = "${var.project_name}-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# HTTP from anywhere (the app)
resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
  description       = "App access - HTTP from anywhere for demo"
}

# SSH (intentionally permissive for demo purposes — pipeline will flag this)
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH access - pipeline should flag 0.0.0.0/0 as CRITICAL"
}

# Outbound — allow all (standard for internet-facing apps)
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound traffic"
}

# ---------------------------------------------------------------------------
# EC2 Instance — Runs the demo Node.js app
# 
# COST: t2.micro = ~$8.50/month if running 24/7. Use terraform destroy when idle.
# The user_data script installs Node and runs the app on boot.
# ---------------------------------------------------------------------------
resource "aws_instance" "demo" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  ebs_optimized          = true
  monitoring             = true

  # EBS encryption — tfsec: aws-ec2-enable-at-rest-encryption
  root_block_device {
    encrypted = true
  }

  # IMDSv2 required — tfsec: aws-ec2-enforce-http-token-imds
  metadata_options {
    http_tokens = "required"
  }

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name        = "${var.project_name}-ec2-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Amazon Linux 2023 AMI (latest) — Node.js in base repos, no extras needed
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# (outputs moved to outputs.tf)

# ---------------------------------------------------------------------------
# INTENTIONALLY VULNERABLE — FOR DEMO ONLY
# These resources are deliberately insecure to demonstrate the pipeline's
# security gates. They will be caught by tfsec and Checkov.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "public_demo" {
  bucket = "cloud-secure-cicd-public-demo"
  acl    = "public-read"
}

resource "aws_vpc_security_group_ingress_rule" "demo_ssh_open" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
