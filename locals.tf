locals {
  common_tags = {
    Owner     = "Clement"
    ManagedBy = "Terraform"
    Project   = "${var.name}"
  }
}


locals {
  aws_region = "eu-west-3"
}