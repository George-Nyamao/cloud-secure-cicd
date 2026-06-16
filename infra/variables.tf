# ---------------------------------------------------------------------------
# variables.tf — All configurable inputs in one place
# 
# PM NOTE: Centralizing variables means:
# 1. Cost changes are visible here (instance_type, region)
# 2. Security boundaries are explicit (allowed_cidr_blocks)
# 3. New environments (staging, prod) just need a new .tfvars file
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources. us-east-1 is cheapest for lab work."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag (dev/staging/prod). Controls naming and cost tracking."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource tags for cost allocation."
  type        = string
  default     = "cloud-secure-cicd"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is free tier eligible (~$8.50/mo if run 24/7)."
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH. Default locks to no one — override with your IP for access."
  type        = string
  default     = "24.27.66.177/32"
  # RISK: 0.0.0.0/0 on SSH is dangerous. Pipeline security scanning (tfsec)
  # will flag this as CRITICAL. Restricted to Pavilion IP after initial scan caught it.
}

variable "key_name" {
  description = "EC2 key pair name for SSH access. Leave empty if not using SSH."
  type        = string
  default     = ""
}
