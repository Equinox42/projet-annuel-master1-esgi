# RDS instance (MySQL)
resource "aws_db_instance" "rds" {
  depends_on             = [aws_db_subnet_group.db_subnet_group]
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_type
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  backup_retention_period = 7
  backup_window = "23:00-00:00"
}

# Subnet group RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# Create SSM parameters for RDS administration

resource "aws_ssm_parameter" "db_username" {
  name  = "/rds/backup/username"
  type  = "SecureString"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/rds/backup/password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/rds/backup/endpoint"
  type  = "String"
  value = aws_db_instance.rds.address
}



