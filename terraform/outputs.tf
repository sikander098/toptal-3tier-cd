output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_ca" {
  description = "EKS cluster certificate authority"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "ecr_web_url" {
  description = "ECR repository URL for web tier"
  value       = aws_ecr_repository.web.repository_url
}

output "ecr_api_url" {
  description = "ECR repository URL for API tier"
  value       = aws_ecr_repository.api.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_hostname" {
  description = "RDS hostname (without port)"
  value       = aws_db_instance.main.address
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "s3_backup_bucket" {
  description = "S3 backup bucket name"
  value       = aws_s3_bucket.backups.id
}

output "eks_oidc_issuer" {
  description = "EKS OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "secrets_manager_arn" {
  description = "ARN of the DB credentials secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}