# Demonstrating the Pipeline

## The Scenario

I created a branch with intentionally insecure resources to verify that the CI/CD pipeline's security gates would detect and block them before any infrastructure reaches AWS:

- An S3 bucket with a `public-read` ACL
- An unrestricted SSH ingress rule (`0.0.0.0/0`)

## The Result

| Step | Result | Screenshot |
|------|--------|------------|
| Push vulnerable branch | Pipeline triggered automatically via PR | |
| **tfsec** | **FAILED** — 8 violations including `aws-s3-block-public-acls`, `aws-s3-no-public-access-with-acl`, `aws-s3-no-public-buckets` | `screenshots/pipeline-blocked.png` |
| **Checkov** | **SKIPPED** — pipeline halted after tfsec failure | |
| **npm audit** | SKIPPED — never reached | |
| **Terraform Plan** | **BLOCKED** — never executed | |
| **Terraform Apply** | **BLOCKED** — never executed | |
| **Smoke Test** | **BLOCKED** — never executed | |

The entire downstream pipeline — Terraform Plan, Apply, and Smoke Test — was skipped because the Security Scan job failed. No infrastructure was provisioned.

## What tfsec Caught

| Rule ID | Severity | Finding |
|---------|----------|---------|
| `aws-s3-block-public-acls` | ERROR | S3 bucket does not block public ACLs |
| `aws-s3-block-public-policy` | ERROR | S3 bucket does not block public policies |
| `aws-s3-enable-bucket-encryption` | ERROR | S3 bucket does not have encryption enabled |
| `aws-s3-enable-versioning` | WARNING | S3 bucket does not have versioning enabled |
| `aws-s3-encryption-customer-key` | ERROR | S3 bucket does not use customer-managed KMS key |
| `aws-s3-ignore-public-acls` | ERROR | S3 bucket does not ignore public ACLs |
| `aws-s3-no-public-access-with-acl` | ERROR | S3 bucket allows public access via ACL |
| `aws-s3-no-public-buckets` | ERROR | S3 bucket is publicly accessible |
| `aws-s3-specify-public-access-block` | NOTE | S3 bucket should specify a public access block |

## Clean Pipeline (main branch)

The same pipeline running against the `main` branch passes all gates successfully:

| Job | Status |
|-----|--------|
| Security Scan | ✅ PASS — all tfsec/Checkov checks clear |
| Terraform Plan | ✅ PASS — valid plan generated |
| Terraform Apply | ✅ PASS — infrastructure provisioned |
| Smoke Test | ✅ PASS — app health check responds 200 |

See `screenshots/pipeline-passing.png`.

## Key Takeaway

The pipeline caught all 8 tfsec violations in under 30 seconds, before any infrastructure was provisioned. The downstream jobs (Terraform Plan, Apply, Smoke Test) never ran — the security gate acted as a hard stop.

Without these gates, the public S3 bucket would have been deployed to AWS, discoverable by attackers, and potentially serving unauthorized content at $0.09/GB egress. The SSH rule would have left the EC2 instance open to brute-force attacks from any IP.
