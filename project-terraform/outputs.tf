# output "rds_cluster_endpoint" {
#   value = data.aws_rds_cluster.rds_endpoint.endpoint
# }

output "base_url" {
  description = "Api Gateway invokation url"
  value = "${aws_api_gateway_deployment.api_deployments.invoke_url}"
}

output "rds_endpoint" {
  description = "Rds Endpoint"
  value = aws_rds_cluster.aurora_postgresql.endpoint
}

output "ecr_repo_url" {
  value = data.aws_ecr_repository.existing_repo.repository_url
}

