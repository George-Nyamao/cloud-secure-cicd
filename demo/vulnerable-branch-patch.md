# ---------------------------------------------------------------------------
# DEMO BRANCH INSTRUCTIONS — "Pipeline caught bad infrastructure"
#
# PURPOSE: Create a branch with intentionally insecure Terraform, push it,
# and watch the pipeline fail. This is your interview story in action.
#
# To create the demo branch:
#   git checkout -b demo/vulnerable-infra
#   # Apply the patch below to infra/main.tf
#   git add . && git commit -m "demo: intentionally vulnerable config"
#   git push origin demo/vulnerable-infra
#   # Open a PR → watch pipeline fail → screenshot the failure
# ---------------------------------------------------------------------------

# ---- PATCH: Apply to infra/main.tf ----
# This adds a publicly accessible S3 bucket and makes the SG even worse.

--- a/infra/main.tf
+++ b/infra/main.tf
 
+# ===== INTENTIONALLY VULNERABLE — FOR DEMO ONLY =====
+# This block will be caught by tfsec (critical) and Checkov (CIS violation).
+# The pipeline will refuse to deploy. That's the point.
+
+# Public S3 bucket — tfsec flags: "aws-s3-block-public-acls"
+# Checkov flags: "CKV_AWS_20: S3 Bucket has an ACL defined which allows public access"
+resource "aws_s3_bucket" "public_demo" {
+  bucket = "cloud-secure-cicd-public-demo-${replace(timestamp(), ":", "-")}"
+  acl    = "public-read"
+
+  tags = {
+    Name        = "cloud-secure-cicd-public-demo"
+    Environment = "demo"
+    Warning     = "INTENTIONALLY VULNERABLE — FOR PIPELINE DEMO ONLY"
+  }
+}
+
+# Open SSH to the world — both tfsec and Checkov flag this
+# tfsec: "aws-vpc-no-public-ingress-sg"
+# Checkov: "CKV_AWS_24: Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
+resource "aws_vpc_security_group_ingress_rule" "demo_ssh_open" {
+  security_group_id = aws_security_group.demo_sg.id
+  cidr_ipv4         = "0.0.0.0/0"
+  from_port         = 22
+  to_port           = 22
+  ip_protocol       = "tcp"
+  description       = "INTENTIONALLY OPEN SSH — DEMO PURPOSES"
+}

# ---- EXPECTED PIPELINE OUTPUT ----

# tfsec will fail with:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ CRITICAL: Resource 'aws_s3_bucket.public_demo' defines a       │
#   │ publicly accessible S3 bucket. Prevent by blocking public ACLs. │
#   │ ID: aws-s3-block-public-acls                                   │
#   └─────────────────────────────────────────────────────────────────┘
#
# Checkov will fail with:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ FAIL: CKV_AWS_20: S3 Bucket has an ACL defined which allows    │
#   │ public access.                                                  │
#   │ Guide: https://docs.bridgecrew.io/docs/s3_1                     │
#   └─────────────────────────────────────────────────────────────────┘
#
# The pipeline stops here. No terraform plan, no deploy.
# Only the secure main branch gets deployed.

# ---- SCREENSHOT SETUP ----
# After creating the PR, capture these screenshots for your repo:
# 1. GitHub Actions workflow run showing the FAILED check
# 2. Click into the failed step → show the tfsec output with the CRITICAL finding
# 3. The PR's "Checks" tab showing the red X
# 4. Fix the branch (revert the patch), push again → show the green checkmark
