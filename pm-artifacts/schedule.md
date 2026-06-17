# Project Schedule — Cloud Secure CI/CD Pipeline
> Start date: TBD | 6-day build

```mermaid
gantt
    title Cloud Secure CI/CD Pipeline
    dateFormat  YYYY-MM-DD
    section Phase 1 - Foundation
    App + Terraform Infra       :p1, 1d
    
    section Phase 2 - Automation
    CI/CD Pipeline              :p2, 1d
    Security Scanning           :p3, 1d
    
    section Phase 3 - Demo
    Vulnerable Branch Demo      :p4, 1d
    Screenshots + Documentation :p5, 1d
    
    section Phase 4 - PM
    Risk + Cost + Scope Docs    :p6, 1d
    README + Interview Prep     :p7, 1d
```

## Day-by-Day

| Day | Phase | Deliverable | Time | Dependencies |
|-----|-------|------------|------|-------------|
| 1 | Foundation | App (Express.js) + Terraform (VPC, EC2, S3, SG) | 2 hrs evening | None |
| 2 | Automation | GitHub Actions pipeline (lint → plan → apply → smoke test) | 2 hrs evening | Day 1 infra |
| 3 | Security | tfsec + Checkov + npm audit integrated into pipeline | 3 hrs weekend | Day 2 pipeline |
| 4 | Demo | `demo/vulnerable-infra` branch + pipeline failure screenshots | 3 hrs weekend | Day 3 security gates |
| 5 | PM Docs | Risk register, cost estimate, scope statement, schedule | 2 hrs evening | Days 1-4 complete |
| 6 | Ship | README, cleanup, interview story practice | 2 hrs evening | All prior phases |

## Critical Path

```
Day 1 (infra) → Day 2 (pipeline) → Day 3 (security scanning)
                                            ↓
                              Day 4 (demo — needs security gates working)
                                            ↓
                              Day 5 (PM docs — needs full project understanding)
                                            ↓
                              Day 6 (README + polish)
```

**Float:** PM docs (Day 5) can run in parallel with Demo (Day 4) if you want to compress to 5 days.
