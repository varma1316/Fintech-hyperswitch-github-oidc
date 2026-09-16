# ==============================================================================
# GitHub Actions Secrets (AWS_ROLE_ARN)
# ==============================================================================

# 1. Terraform Repository: Stores the Terraform IAM Role ARN
resource "github_actions_secret" "terraform_role" {
  repository      = var.terraform_repo_name
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = aws_iam_role.terraform_role.arn
}

# 2. Frontend Repository: Stores the Frontend IAM Role ARN
resource "github_actions_secret" "frontend_role" {
  repository      = var.frontend_repo_name
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = aws_iam_role.frontend_role.arn
}

# 3. Backend Repository: Stores the Backend IAM Role ARN
resource "github_actions_secret" "backend_role" {
  repository      = var.backend_repo_name
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = aws_iam_role.backend_role.arn
}

# 4. Terraform Repository: Stores the Remote State S3 Bucket Name
resource "github_actions_secret" "terraform_state_bucket" {
  count           = var.state_bucket_name != null ? 1 : 0
  repository      = var.terraform_repo_name
  secret_name     = "TF_STATE_BUCKET"
  plaintext_value = var.state_bucket_name
}
