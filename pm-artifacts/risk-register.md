# Risk Register — Cloud Secure CI/CD Pipeline
> Prepared: June 2026 | Owner: George Nyamao

| ID | Risk | Category | Likelihood | Impact | Score | Mitigation | Contingency |
|----|------|----------|-----------|--------|-------|------------|-------------|
| R1 | S3 bucket misconfigured as public | Security | Medium | High (data exposure) | **High** | tfsec scan in pipeline blocks public ACLs | Pipeline fails deploy; alert sent to Slack |
| R2 | SSH port open to 0.0.0.0/0 | Security | High | High (brute force) | **Critical** | Checkov scan flags permissive ingress rules | Pipeline fails; developer must restrict CIDR |
| R3 | Terraform state file exposed | Security | Low | Critical (infra secrets) | **High** | S3 block-public-access enabled + versioning | Restore from prior version; rotate credentials |
| R4 | AWS costs exceed budget | Cost | Medium | Low ($8.50/mo max) | **Low** | t2.micro only; terraform destroy when idle | AWS budget alert at $15/month |
| R5 | Pipeline CI/CD credentials leak | Security | Low | Critical | **High** | GitHub Actions OIDC instead of long-lived keys | Rotate keys; revoke compromised access |
| R6 | tfsec/Checkov false positive blocks legit change | Operational | Medium | Low (delay) | **Low** | Add skip/ignore annotations per finding | Document in PR why finding is acceptable |
| R7 | Dependency vulnerability in app | Security | Medium | Medium | **Medium** | npm audit in pipeline; fail on high+ | Update dependency version; re-scan |
| R8 | Pipeline not run on PR (only push) | Process | Low | Medium | **Low** | Pipeline runs on both push AND PR triggers | Documented as risk — user must verify PRs |

## Risk Response Plan

**Critical (R2):** Immediate pipeline failure. Developer cannot merge until CIDR is restricted. Documented exception process for lab environments.

**High (R1, R3, R5):** Pipeline failure. Escalate to project lead (self-review). Accept with documented justification in PR comments.

**Medium (R6, R7):** Pipeline warning (not failure). Developer must address before merge. False positives annotated in `.tfskip` or inline comments.

**Low (R4, R8):** Documented and accepted. No pipeline impact.
