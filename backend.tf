terraform {
  # When running aws_github_oidc locally from your machine, keep this backend block
  # commented to use local state.
  #
  # If you want to migrate aws_github_oidc state to the remote S3 bucket after creation:
  # uncomment the block below and run:
  # terraform init -migrate-state -backend-config="bucket=<YOUR_STATE_BUCKET>"
  #
   backend "s3" {
     key     = "github_oidc/terraform.tfstate"
     region  = "us-east-1"
     encrypt = true
   }
}

