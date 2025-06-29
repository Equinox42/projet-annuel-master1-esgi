# Launch Template for the AutoScaling Group EC2 WEB

resource "aws_launch_template" "launch_template" {
  name = "${var.name}-launch-template"

  instance_type                        = var.instance_type
  image_id                             = var.image_id
  vpc_security_group_ids               = [aws_security_group.sg_ec2_web.id]
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = true
  user_data                            = filebase64("${path.module}/scripts/user_data_web.sh")

  iam_instance_profile {
    name = "ec2_web_profile"
  }

    tags = {
    Name = "ec2-web"
  }
}


# AutoScalingGroup

resource "aws_autoscaling_group" "asg_web" {
  depends_on = [aws_db_instance.rds]
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}

# Create a new ALB Target Group attachment

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_web.id
  lb_target_group_arn    = aws_lb_target_group.alb_tg.arn
}