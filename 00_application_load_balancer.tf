# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.common_tags

}

# Target Group for ALB
resource "aws_lb_target_group" "alb_tg" {
  name     = "terraform-alb-tg"
  protocol = "HTTP"
  port     = 80
  vpc_id   = module.vpc.vpc_id
  tags     = local.common_tags
}

# Listener for the application load balancer
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  tags = local.common_tags
}

