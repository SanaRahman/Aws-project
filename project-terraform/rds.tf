#_____________SERVERLESS DB SETUP_____________

# Amazon Aurora Serverless Cluster for PostgreSQL
resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier     = "aurora-postgresql"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = var.arora_engine_v
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  port                    = "5432"
  skip_final_snapshot    = true
  # availability_zones     = [var.private_subnet2_ava_zone]
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
  tags = merge(var.tags, {
        Name    = "Aurora_Serverless_Cluster"
  })

}

# Amazon Aurora Serverless Cluster Instance for PostgreSQL
resource "aws_rds_cluster_instance" "aurora_postgresql_instance" {
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class     = var.rds_cluster_instance_class
  engine             = aws_rds_cluster.aurora_postgresql.engine
  engine_version     = aws_rds_cluster.aurora_postgresql.engine_version
}

