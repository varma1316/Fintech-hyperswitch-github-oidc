# ==============================================================================
# 1. Terraform IAM Role (Admin Access)
# ==============================================================================

resource "aws_iam_role" "terraform_role" {
  name        = "${var.project_name}-github-terraform-role"
  description = "IAM role for GitHub Actions in the Terraform repository (Admin access)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.terraform_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-terraform-role"
  }
}

# Attach AdministratorAccess to Terraform role
resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ==============================================================================
# 2. Frontend IAM Role (CloudFront, S3, Secrets Access)
# ==============================================================================

resource "aws_iam_role" "frontend_role" {
  name        = "${var.project_name}-github-frontend-role"
  description = "IAM role for GitHub Actions in Frontend repository (S3, CloudFront, Secrets)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.frontend_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-frontend-role"
  }
}

resource "aws_iam_policy" "frontend_policy" {
  name        = "${var.project_name}-github-frontend-policy"
  description = "Permissions for frontend CI/CD deployment: S3 sync, CloudFront invalidation, Secrets access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3DeploymentAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::*frontend*",
          "arn:aws:s3:::*frontend*/*",
          "arn:aws:s3:::*${var.project_name}*",
          "arn:aws:s3:::*${var.project_name}*/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidationAccess"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecretsAndSSMAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "frontend_attachment" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = aws_iam_policy.frontend_policy.arn
}

# ==============================================================================
# 3. Backend IAM Role (ECR, EKS, Secrets Access)
# ==============================================================================

resource "aws_iam_role" "backend_role" {
  name        = "${var.project_name}-github-backend-role"
  description = "IAM role for GitHub Actions in Backend repository (ECR, EKS, Secrets)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.backend_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-backend-role"
  }
}

# ECR Push/Pull permissions
resource "aws_iam_role_policy_attachment" "backend_ecr" {
  role       = aws_iam_role.backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy" "backend_eks_secrets_policy" {
  name        = "${var.project_name}-github-backend-policy"
  description = "Permissions for backend CI/CD: EKS cluster access and Secrets retrieval"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecretsAndSSMAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backend_eks_secrets" {
  role       = aws_iam_role.backend_role.name
  policy_arn = aws_iam_policy.backend_eks_secrets_policy.arn
}
