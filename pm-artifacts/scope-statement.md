# Scope Statement — Cloud Secure CI/CD Pipeline
> Version 1.1 | June 2026 | Status: Delivered

## In Scope

- **Infrastructure as Code:** Terraform provisioning for EC2, S3 remote state, security groups, and supporting AWS data sources
- **CI/CD Pipeline:** GitHub Actions workflow triggered on push and pull request activity for `main`
- **Security Scanning:** tfsec for infrastructure risk, Checkov for compliance checks, and npm audit for dependency risk
- **Automated Deploy:** Terraform plan and apply after security gates pass
- **Smoke Test:** HTTP health-check verification after deployment
- **Documentation:** README, architecture summary, risk register, cost estimate, schedule, and scope statement
- **Demo:** A vulnerable branch / PR that proves the pipeline blocks insecure infrastructure before deployment

## Out of Scope (v1.0)

| Item | Reason | Future Consideration |
|------|--------|---------------------|
| Multi-region deployment | Unnecessary complexity for a focused portfolio demo | v2.0 |
| Production-grade OIDC federation | GitHub secrets are sufficient for this lab scope | Replace long-lived AWS keys in a production version |
| Auto-scaling / Load Balancer | A single EC2 instance keeps cost and architecture easy to explain | v2.0 |
| Database (RDS) | The app is stateless by design | Not planned for v1.x |
| Containerization (Docker/ECS) | Direct EC2 deployment keeps the security-gate story clear | v2.0 |

## Acceptance Criteria

The project is complete when:

1. [x] `terraform apply` creates a working EC2 instance serving the app
2. [x] Pushing to main triggers the GitHub Actions pipeline
3. [x] Pipeline runs tfsec + Checkov + npm audit before any deploy
4. [x] Pipeline blocks deploy on critical security findings
5. [x] Creating the vulnerable demo branch / PR causes the pipeline to fail at the security gate
6. [x] Fixing the insecure config allows the pipeline to pass
7. [x] Risk register documents identified project risks with mitigation and contingency
8. [x] Cost estimate demonstrates financial awareness and cleanup controls

## Constraints

- AWS Free Tier / low-cost lab target
- Target monthly cost under $15 if left running
- Single AWS region: `us-east-1`
- No production data
- Single developer / self-service operating model
- Destroy workflow or `terraform destroy` should be used after demos to avoid idle EC2 cost

## Delivery Evidence

- Main branch workflow passed end-to-end with security scan, Terraform plan, Terraform apply, and smoke test jobs successful.
- Vulnerable demo run failed at tfsec; downstream deployment jobs were skipped.
- Screenshots are stored in `screenshots/pipeline-passing.png` and `screenshots/pipeline-blocked.png`.
- Demo write-up is stored in `demo/vulnerable-branch-patch.md`.
