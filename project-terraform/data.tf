data "aws_rds_cluster" "rds_endpoint" {
  cluster_identifier = aws_rds_cluster.aurora_postgresql.cluster_identifier
}

data "aws_ecr_repository" "existing_repo" {
  name = var.ecr_repository_name
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name # Replace with your actual domain
  private_zone = false
}

# data "aws_rds_cluster" "rds_endpoint" {
#   cluster_identifier = aws_rds_cluster.aurora_postgresql.cluster_identifier
# }

# data "aws_rds_cluster" "rds" {
#   cluster_identifier = "aurora-postgresql"
# }