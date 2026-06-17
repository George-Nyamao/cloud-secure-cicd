# Cost Estimate — Cloud Secure CI/CD Pipeline
> Estimated monthly costs, us-east-1, June 2026

| Resource | Configuration | Monthly Cost | Notes |
|----------|--------------|-------------|-------|
| EC2 t2.micro | 1 instance, 24/7 | $8.50 | Free tier eligible for 12 months |
| S3 (state bucket) | Small, versioning enabled | $0.50 | Negligible for state files |
| S3 (app data) | Not used in demo | $0.00 | Add if needed |
| CloudWatch Logs | Minimal (EC2 logs) | $1.00 | 30-day retention |
| Data Transfer | Minimal (demo traffic) | $0.50 | Under 1GB/month |
| **Total (estimated)** | | **~$10.50/mo** | |

## What This Cost Buys

| Item | Value |
|------|-------|
| Terraform-managed infra | Repeatable, auditable, destroyable |
| Security scanning (tfsec) | Catches misconfigurations before prod |
| Compliance scanning (Checkov) | Maps to CIS Benchmarks |
| CI/CD automation | Zero-touch deploy on push |
| Risk mitigation | Avoids $10K+ breach cleanup costs |

## Cost of NOT having this pipeline

| Incident | Average Cost (AWS) |
|----------|-------------------|
| Public S3 bucket data exposure | $50K-$500K+ per incident |
| SSH brute force compromise | $10K-$100K forensic + remediation |
| Deploy without review | Priceless (reputation + compliance fines) |

**ROI:** The pipeline costs ~$10/month. One caught misconfiguration pays for 100+ years of operation.

## Destruction Policy

```bash
# Destroy all resources when not in use:
terraform destroy -auto-approve

# Verify destroyed:
aws ec2 describe-instances --filters "Name=tag:Project,Values=cloud-secure-cicd"
```
