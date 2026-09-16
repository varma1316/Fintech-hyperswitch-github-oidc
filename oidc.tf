# Fetch GitHub's OIDC OpenID configuration and TLS certificate thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# AWS IAM OpenID Connect Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Dynamically retrieved fingerprint with well-known GitHub DigiCert fallback thumbprints
  thumbprint_list = distinct([
    data.tls_certificate.github.certificates[0].sha1_fingerprint,
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ])

  tags = {
    Name = "${var.project_name}-github-oidc-provider"
  }
}
