# Scope Statement — Cloud Secure CI/CD Pipeline
> Version 1.0 | June 2026

## In Scope

- **Infrastructure as Code:** Terraform modules provisioning VPC, EC2, S3, Security Groups
- **CI/CD Pipeline:** GitHub Actions workflow triggered on push/PR to main
- **Security Scanning:** tfsec (infra), Checkov (compliance), npm audit (dependencies)
- **Automated Deploy:** Terraform plan + apply on successful scan
- **Smoke Test:** Health check verification post-deploy
- **Documentation:** README, architecture, risk register, cost estimate, schedule
- **Demo:** A vulnerable branch that demonstrates pipeline blocking insecure infrastructure

## Out of Scope (v1.0)

| Item | Reason | Future Consideration |
|------|--------|---------------------|
| Multi-region deployment | Unnecessary complexity for demo | v2.0 |
| Production-grade auth (OIDC) | GitHub secrets sufficient for demo | When SAML/SSO required |
| Auto-scaling / Load Balancer | t2.micro single instance is the point | v2.0 |
| Database (RDS) | App is stateless by design | Not planned |
| Containerization (Docker/ECS) | EC2 direct deployment is simpler demo | v2.0 |

## Acceptance Criteria

The project is complete when:

1. [ ] `terraform apply` creates a working EC2 instance serving the app
2. [ ] Pushing to main triggers GitHub Actions pipeline
3. [ ] Pipeline runs tfsec + Checkov + npm audit before any deploy
4. [ ] Pipeline blocks deploy on critical security findings
5. [ ] Creating `demo/vulnerable-infra` branch causes pipeline to fail
6. [ ] Fixing the insecure config allows the pipeline to pass
7. [ ] Risk register documents all identified project risks
8. [ ] Cost estimate demonstrates financial awareness

## Constraints

- AWS Free Tier eligible (t2.micro)
- < $15/month operating cost
- Single region (us-east-1)
- No production data
- Single developer (self-service)
