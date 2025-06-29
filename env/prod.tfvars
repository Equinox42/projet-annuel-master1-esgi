## Global

name = "m1-projet-annuel"

## Database

db_name = "m1srcdatabase"
db_username = "m1user"
db_password = "m1password"
db_instance_type = "db.t3.micro"

## VPC

cidr = "10.0.0.0/16"
azs = ["eu-west-3a", "eu-west-3b"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

## Autoscaling

min_size = 2
max_size = 5
desired_capacity = 3


