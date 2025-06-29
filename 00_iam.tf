data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#############
## EC2 WEB ##
#############


# IAM Instance Profile for EC2 WEB Instances

resource "aws_iam_instance_profile" "ec2_web_profile" {
  name = "ec2_web_profile"
  role = aws_iam_role.ec2_web_role.name
}

# IAM Role for EC2 WEB Instances

resource "aws_iam_role" "ec2_web_role" {
  name               = "ec2_web_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


#################
## EC2 BASTION ##
#################

# IAM Instance Profile for EC2 Bastion

resource "aws_iam_instance_profile" "ec2_bastion_profile" {
  name = "ec2_bastion_profile"
  role = aws_iam_role.ec2_web_role.name
}

# IAM Role for Ec2 Bastion 
resource "aws_iam_role" "ec2_bastion_role" {
  name               = "ec2_bastion_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


######################
## Managed Policies ##
######################

# IAM Policy for SSM Session Manager

resource "aws_iam_role_policy_attachment" "ssm_agent_policy" {
  for_each   = toset([
    aws_iam_role.ec2_web_role.name,
    aws_iam_role.ec2_bastion_role.name
  ])
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = each.value
}

# IAM Policy for CloudWatch Agent

resource "aws_iam_role_policy_attachment" "cw_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ec2_web_role.name
}



#####################
## Custom Policies ##
#####################

# IAM Policy to Allow ec2 to fetch data from s3
resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnly"
  description = "Allow ec2 to manage files in S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::${var.name}-scripts-bucket",
        "arn:aws:s3:::${var.name}-scripts-bucket/*"
      ]
    }]
  })
}

# IAM Policy to allow Bastion to fetch SSM parameters

data "aws_caller_identity" "current" {}


resource "aws_iam_policy" "ssm_parameters_read_only" {
  name        = "SSMParametersReadOnly"
  description = "Allow read access to SSM parameters under /rds/backup/, including SecureString"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:${local.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/rds/backup/*"
      },
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = "*"
      }
    ]
  })
}

# Attach SSM Policy to ec2_web_role and ec2_bastion_role

resource "aws_iam_role_policy_attachment" "ssm_parameters_read_only_attachment" {
  for_each   = toset([
    aws_iam_role.ec2_web_role.name,
    aws_iam_role.ec2_bastion_role.name
  ])

  policy_arn = aws_iam_policy.ssm_parameters_read_only.arn
  role       = each.value
}


# Attach s3 Policy to ec2_web_role and ec2_bastion_role

resource "aws_iam_role_policy_attachment" "s3_read_only_attachment" {
  for_each   = toset([
    aws_iam_role.ec2_web_role.name,
    aws_iam_role.ec2_bastion_role.name
  ])

  policy_arn = aws_iam_policy.s3_read_only.arn
  role       = each.value
}