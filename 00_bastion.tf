resource "aws_instance" "bastion" {
  depends_on = [aws_db_instance.rds]
  ami                         = var.image_id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_bastion_profile.name
  user_data                   = filebase64("${path.module}/scripts/user_data_bastion.sh")

  tags = {
     Name = "ec2-bastion"
  }
}