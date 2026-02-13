# AWS Secrets Manager — stores database credentials
# The External Secrets Operator syncs this into K8s Secrets

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/db-credentials"
  description             = "Database credentials for the ${var.project_name} application"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    DBUSER = var.db_username
    DBPASS = var.db_password
    DB     = var.db_name
    DBHOST = aws_db_instance.main.address
    DBPORT = "5432"
  })
}

# IAM Policy — allows reading this specific secret
resource "aws_iam_policy" "external_secrets" {
  name        = "${var.project_name}-external-secrets-policy"
  description = "Allow External Secrets Operator to read Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.db_credentials.arn]
      }
    ]
  })
}

# IRSA Role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:toptal:external-secrets-sa"
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  policy_arn = aws_iam_policy.external_secrets.arn
  role       = aws_iam_role.external_secrets.name
}
