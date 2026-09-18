# ==============================================================================
# S3 Bucket for Terraform Remote State (Shared across all projects)
# ==============================================================================

resource "aws_s3_bucket" "terraform_state" {
  count         = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket        = var.state_bucket_name
  force_destroy = false

  tags = {
    Name        = var.state_bucket_name
    Description = "Terraform remote state storage shared across projects"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==============================================================================
# Folder Placeholders in State Bucket
# ==============================================================================

# Folder for aws_github_oidc state files
resource "aws_s3_object" "github_oidc_folder" {
  count   = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket  = aws_s3_bucket.terraform_state[0].id
  key     = "github_oidc/"
  content = ""
}

# Folder for hyperswitch-solution/terraform infrastructure state files
resource "aws_s3_object" "terraform_folder" {
  count   = var.create_state_bucket && var.state_bucket_name != null ? 1 : 0
  bucket  = aws_s3_bucket.terraform_state[0].id
  key     = "terraform/"
  content = ""
}
