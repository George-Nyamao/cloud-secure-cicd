# ---------------------------------------------------------------------------
# outputs.tf — What gets created, exposed for CI/CD and documentation
# 
# PM NOTE: Outputs serve two purposes:
# 1. CI/CD pipeline reads them for smoke tests (curl the app URL)
# 2. Cost tracking: knowing exactly what was provisioned
# ---------------------------------------------------------------------------

output "app_url" {
  description = "URL to access the demo application"
  value       = "http://${aws_instance.demo.public_ip}:3000"
}

output "instance_id" {
  description = "EC2 instance ID for troubleshooting and cost tracking"
  value       = aws_instance.demo.id
}

output "security_group_id" {
  description = "Security group ID controlling inbound access"
  value       = aws_security_group.demo_sg.id
}
