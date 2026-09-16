variable "aws_region" {
  type        = string
  description = "AWS region for provisioning resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for IAM roles and resource tagging"
  default     = "hyperswitch"
}

variable "github_owner" {
  type        = string
  description = "GitHub username or organization owning the repositories"
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token with repo and secrets write permissions (can also be supplied via GITHUB_TOKEN environment variable)"
  default     = null
  sensitive   = true
}

variable "terraform_repo_name" {
  type        = string
  description = "GitHub repository name for Terraform infrastructure"
}

variable "frontend_repo_name" {
  type        = string
  description = "GitHub repository name for Frontend application"
}

variable "backend_repo_name" {
  type        = string
  description = "GitHub repository name for Backend microservices"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for storing Terraform remote state"
  default     = null
}

variable "create_state_bucket" {
  type        = bool
  description = "Whether to provision the remote state S3 bucket in this module"
  default     = false
}
