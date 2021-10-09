# adds primary automation policy and role
resource "aws_iam_policy" "ingress_prj_robot" {
    name = "ingress_prj_robot_policy"
    path = "/"
    description = "Primary automation policy for application resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "lambda:*",
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchEventsFullAccess",
      "Effect": "Allow",
      "Action": "events:*",
      "Resource": "*"
    },
    {
      "Sid": "IAMPassRoleForCloudWatchEvents",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::*:role/AWS_Events_Invoke_Targets"
    }
  ]
}
EOF
    tags = {
        terraform = "true"
    }
}

resource "aws_iam_role" "ingress_prj_robot" {
  name = "ingress_prj_robot"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ingress_prj_robot_attachment" {
  role       = aws_iam_role.ingress_prj_robot.name
  policy_arn = aws_iam_policy.ingress_prj_robot.arn
}
