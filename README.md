# Cloud Secure CI/CD

Infrastructure-as-Code for a cloud security pipeline — starting with the app and AWS infrastructure. CI/CD automation and security scanning gates coming next.

## What's Here

### App — Node.js Health-Check API

A lightweight Express server that serves as the deployment target. Single endpoint for verifying the application is running after deployment.

```bash
cd app
npm install
npm start
# → http://localhost:3000/health
```

### Infrastructure — Terraform (AWS)

HashiCorp Terraform configuration that provisions:

| Resource | Purpose |
|----------|---------|
| **VPC** | Default VPC with subnets |
| **Security Group** | HTTP (port 3000) and SSH ingress rules |
| **EC2 Instance** | t2.micro (Free Tier) running Amazon Linux 2 |
| **S3 Bucket** | Terraform state storage with versioning and public access blocked |

The SSH ingress rule defaults to `0.0.0.0/0` — intentionally permissive for now. A security scanning step will flag and block this in a later phase.

```bash
cd infra
terraform init
terraform plan
```

### Project Structure

```
cloud-secure-cicd/
├── app/
│   ├── package.json       # Node.js project manifest
│   └── server.js          # Express health-check API
├── infra/
│   ├── main.tf            # Core: VPC, EC2, S3, Security Groups
│   ├── variables.tf       # Configurable inputs
│   ├── outputs.tf         # Infrastructure outputs (app URL, instance ID)
│   └── user_data.sh       # EC2 boot script (installs Node, runs app)
├── .gitignore
└── README.md
```

## Prerequisites

- **AWS account** (Free Tier eligible)
- **IAM user** with `AmazonEC2FullAccess` and `AmazonS3FullAccess` permissions
- **Terraform** v1.5+
- **Node.js** 18+

## Quick Start

```bash
# 1. Clone
git clone https://github.com/George-Nyamao/cloud-secure-cicd.git
cd cloud-secure-cicd

# 2. Deploy infrastructure
cd infra
terraform init
terraform apply

# 3. Get the app URL
terraform output app_url
# → http://<EC2_PUBLIC_IP>:3000

# 4. Verify
curl http://<EC2_PUBLIC_IP>:3000/health
# → {"status":"ok","timestamp":"...","version":"1.0.0"}
```

## Cost

~$10.50/month (EC2 t2.micro $8.50, S3 $0.50, data transfer $1.00, CloudWatch $0.50). Destroy with `terraform destroy` when not in use.

## Roadmap

- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Security scanning (tfsec, Checkov)
- [ ] Dependency auditing (npm audit)
- [ ] Automated deployment with security gates
- [ ] Post-deploy smoke tests
