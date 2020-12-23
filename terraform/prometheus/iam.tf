resource "aws_iam_instance_profile" "ec2_prometheus" {
  name = "EC2_Prometheus"
  role = aws_iam_role.ec2_prometheus.name
}

resource "aws_iam_role" "ec2_prometheus" {
  name               = "EC2_Prometheus"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ec2_describe_instances" {
  name   = "EC2_Describe_Instances"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:DescribeInstances",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_describe_instance" {
  role       = aws_iam_role.ec2_prometheus.name
  policy_arn = aws_iam_policy.ec2_describe_instances.arn
}
