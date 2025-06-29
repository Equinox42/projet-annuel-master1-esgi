variable "name" {
  description = "name that will be passed to all the resources created by terraform, so it's easier to identify them"
  type        = string
}

## VPC

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "azs" {
  description = "A list of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of CIDR block for public subnet"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR block for private subnet"
  type        = list(string)
}

## ASG

variable "min_size" {
  description = "minimum instances that the asg will maintain no matter what"
  type        = number
  validation {
    condition     = var.min_size <= 2
    error_message = "min size allowed of instances is 2"
  }
}

variable "max_size" {
  description = "number of instances that the asg will never exceed"
  type        = number
  validation {
    condition     = var.max_size <= 5
    error_message = "chillout, that's just a test environment"
  }
}

variable "desired_capacity" {
  description = "number of instances that the asg will create at launch"
  type        = number
  validation {
    condition     = var.desired_capacity <= 5
    error_message = "Got to be 3 deal with it"
  }
}

variable "image_id" {
  description = "Id of the AMI that should be used by the ASG"
  type        = string
  default     = "ami-0160e8d70ebc43ee1"
}

variable "instance_type" {
  description = "Instance type used by the ASG"
  type        = string
  default     = "t2.micro"
}

## Database 

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}


variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  sensitive = true
}

variable "db_instance_type" {
  description = "Instance type for RDS"
  type        = string
}


variable "expiration_days" {
  type    = number
  default = 30
}
