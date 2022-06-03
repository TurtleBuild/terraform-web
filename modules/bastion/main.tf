data "aws_region" "now" {}
data "aws_caller_identity" "self" {}

###########################################################################
# EC2
###########################################################################
resource "aws_autoscaling_group" "main" {
  name                = "${var.bastion_name}-bastion"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }
}
resource "aws_launch_template" "main" {
  name          = "${var.bastion_name}-bastion"
  image_id      = "ami-02c3627b04781eada"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.bastion_name}-bastion"
    }
  }
}
resource "aws_iam_instance_profile" "ssm" {
  name = "${var.bastion_name}-bastion"
  role = aws_iam_role.ec2.name
}

###########################################################################
# IAM
###########################################################################

# ec2の信頼ポリシーを作成
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# EC2インスタンス用IAMロールを作成
resource "aws_iam_role" "ec2" {
  name               = "${var.bastion_name}-bastion"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}
# SSM管理ポリシーをEC2インスタンス用IAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# SSHアクセス用IAMポリシーの作成
data "aws_iam_policy_document" "ssh" {
  statement {
    effect  = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:${data.aws_region.now.name}:${data.aws_caller_identity.self.account_id}:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Name"
      values   = ["${var.bastion_name}-bastion"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ssm:*:*:document/AWS-StartSSHSession"]
  }
  statement {
    effect  = "Allow"
    actions = ["ec2-instance-connect:SendSSHPublicKey"]
    resources = [
      "arn:aws:ec2:${data.aws_region.now.name}:${data.aws_caller_identity.self.account_id}:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"
      values   = ["${var.bastion_name}-bastion"]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:osuser"
      values   = [var.bastion_user]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}
# 踏み台接続用IAMグループの作成
# NOTE: コンソール画面にて、踏み台への接続を許可したいIAMユーザーを当該グループに追加する
resource "aws_iam_group" "bastion_users" {
  name = "${var.bastion_name}-bastion-users"
  path = "/users/"
}
# SSHアクセス用IAMポリシーを踏み台接続用IAMグループにアタッチ
resource "aws_iam_group_policy" "bastion_users" {
  name   = "${var.bastion_name}-bastion-users"
  group  = aws_iam_group.bastion_users.name
  policy = data.aws_iam_policy_document.ssh.json
}
