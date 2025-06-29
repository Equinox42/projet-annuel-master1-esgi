## Security Groups for the Application Load Balancer

resource "aws_security_group" "sg_alb" {
  name        = "sg_alb"
  description = "Allow port 80 and 443 inbound traffic and all outbound traffic for the ALB"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "sg_alb"
  }
}


## Rules to attach to the application load balancer security group


# HTTP Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_http_ingress_rule_ipv4" {

  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_ingress_rule_ipv6" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# HTTPS Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_https_ingress_rule_ipv4" {

  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_ingress_rule_ipv6" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


# Allow all on Egress
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


## Security Groups for the instances behind the Application Load Balancer

resource "aws_security_group" "sg_ec2_web" {
  name        = "sg_ec2_web"
  description = "Allow http from the ALB to the EC2 WEB Instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "sg_ec2_web"
  }
}

## Rules to attach to the ec2 security group
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id            = aws_security_group.sg_ec2_web.id
  referenced_security_group_id = aws_security_group.sg_alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "allow_from_alb" {
  security_group_id = aws_security_group.sg_ec2_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# RDS Security group allow only the EC2 instances to connect
resource "aws_security_group" "sg_rds" {
  name        = "sg_rds"
  description = "Allow access to RDS from EC2 only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.sg_ec2_web.id,
      aws_security_group.sg_bastion.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Security Group for the Bastion instance
resource "aws_security_group" "sg_bastion" {
  name        = "sg_bastion"
  description = "Security group for Bastion instance (SSM only, no SSH)"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_all_ipv6" {
  security_group_id = aws_security_group.sg_bastion.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_all_ipv4" {
  security_group_id = aws_security_group.sg_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}