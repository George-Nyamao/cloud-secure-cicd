# Cloud Secure CI/CD

[![AWS](https://img.shields.io/badge/AWS-Cloud_Security-orange)]()
[![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4)]()
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF)]()
[![tfsec](https://img.shields.io/badge/tfsec-Security-blue)]()
[![Checkov](https://img.shields.io/badge/Checkov-Compliance-green)]()

A CI/CD pipeline that refuses to deploy insecure cloud infrastructure. Every push runs Terraform formatting, tfsec, Checkov, and npm audit before AWS deployment. If the gates pass, GitHub Actions deploys the app to EC2 and runs a post-deploy health check.

## 3-Second Interview Story

**Problem:** Teams can accidentally deploy public storage, open SSH, or vulnerable dependencies when cloud changes bypass security review.

**What I built:** A GitHub Actions pipeline that scans Terraform and application dependencies before deployment, then provisions AWS infrastructure and smoke-tests the running app.

**Result:** The pipeline successfully deployed clean infrastructure on `main` and blocked an intentionally vulnerable PR before Terraform plan or apply could run.

## What This Demonstrates

- Infrastructure as Code with Terraform on AWS
- CI/CD automation with GitHub Actions
- Security gates using tfsec, Checkov, and npm audit
- Deployment controls that separate pull request validation from main-branch apply
- Post-deploy smoke testing against a live `/health` endpoint
- Project-management artifacts: risk register, cost estimate, scope, and schedule

## Architecture

```text
Developer push / PR
        |
        v
GitHub Actions
        |
        +--> Terraform fmt
        +--> tfsec infrastructure scan
        +--> Checkov compliance scan
        +--> npm audit dependency scan
        |
        v
Terraform plan
        |
        v
Terraform apply on main only
        |
        v
AWS EC2 + Security Group + S3 backend
        |
        v
Smoke test: GET /health
```

## Repository Structure

```text
cloud-secure-cicd/
├── app/
│   ├── package.json
│   └── server.js
├── infra/
│   ├── .tfsec/config.yml
│   ├── main.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   └── variables.tf
├── .github/workflows/
│   ├── deploy.yml
│   └── destroy.yml
├── demo/
│   └── vulnerable-branch-patch.md
├── pm-artifacts/
│   ├── cost-estimate.md
│   ├── risk-register.md
│   ├── schedule.md
│   └── scope-statement.md
├── screenshots/
│   ├── pipeline-blocked.png
│   └── pipeline-passing.png
└── README.md
```

## Application

The app is a lightweight Express health-check API used as the deployment target.

```bash
cd app
npm install
npm start
curl http://localhost:3000/health
```

Expected response:

```json
{"status":"ok","timestamp":"...","version":"1.0.0"}
```

## Infrastructure

Terraform provisions a small AWS lab environment:

| Resource | Purpose |
|---|---|
| Default VPC lookup | Uses existing AWS networking to keep the lab simple |
| Security group | Allows app traffic on port 3000 and restricted SSH access |
| EC2 instance | Amazon Linux 2023 host running the Node.js app |
| S3 backend | Remote Terraform state bucket managed by the workflow |

Security defaults are intentionally visible in code. SSH is restricted with `allowed_ssh_cidr`, and the vulnerable demo shows what happens when insecure rules are introduced.

## CI/CD Pipeline

Workflow: `.github/workflows/deploy.yml`

Pipeline stages:

1. **Security Scan**
   - Terraform format check
   - tfsec infrastructure scan
   - Checkov compliance scan
   - npm audit dependency scan
2. **Terraform Plan**
   - Configures AWS credentials
   - Creates the remote state bucket if needed
   - Generates a Terraform plan
3. **Terraform Apply**
   - Runs only on pushes to `main`
   - Applies the approved plan
4. **Smoke Test**
   - Calls the deployed app's `/health` endpoint
   - Fails the workflow if the app does not return HTTP 200

Pull requests run the scan and plan gates. Main-branch pushes run the full deployment.

## Security Gate Demo

The demo branch intentionally added insecure infrastructure:

- Public S3 ACL
- Unrestricted SSH ingress

Result:

- tfsec failed in under 30 seconds
- Checkov, npm audit, Terraform Plan, Terraform Apply, and Smoke Test were skipped
- No vulnerable infrastructure was deployed

Evidence:

- `demo/vulnerable-branch-patch.md`
- `screenshots/pipeline-blocked.png`
- `screenshots/pipeline-passing.png`

## Quick Start

### Local app test

```bash
git clone https://github.com/George-Nyamao/cloud-secure-cicd.git
cd cloud-secure-cicd/app
npm install
npm start
curl http://localhost:3000/health
```

### GitHub Actions deployment

Set these repository secrets before running the deployment workflow:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

The workflow deploys in `us-east-1` and uses the S3 backend bucket configured in `TF_STATE_BUCKET` inside `.github/workflows/deploy.yml`.

### Manual Terraform plan

```bash
cd infra
terraform init \
  -backend-config="bucket=cloud-secure-cicd-tfstate-dev" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=us-east-1"
terraform plan
```

## Destroying the Lab

The repo includes `.github/workflows/destroy.yml` for cleanup. Use it when the demo environment is no longer needed so the EC2 instance does not keep accruing cost.

Manual equivalent:

```bash
cd infra
terraform destroy
```

## Cost

Estimated monthly cost if left running continuously: about **$10.50/month**.

Primary cost drivers:

- EC2 t2.micro: about $8.50/month outside Free Tier
- S3 remote state: under $1/month for this lab
- Data transfer and CloudWatch: low-volume lab usage, about $1/month

The lab should be destroyed after demos to keep cost near zero.

## Project Management Artifacts

The `pm-artifacts/` folder contains:

- `risk-register.md` — risks, likelihood, impact, mitigation, and contingency
- `cost-estimate.md` — monthly cost assumptions and cleanup controls
- `scope-statement.md` — scope boundaries and acceptance criteria
- `schedule.md` — phased delivery plan and critical path

## What I Learned Building This

Security automation is only useful if it becomes a hard deployment gate. A scanner that reports findings after deployment is advisory; this project blocks unsafe infrastructure before Terraform can apply it. The demo branch makes that control visible: the insecure change fails early, downstream jobs are skipped, and AWS never receives the risky configuration.
