resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_exec" {
  name = "my-attachemnt"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_exec_role.name]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda execution role"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces" 
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy_calculate_emsission" {
  name        = "lambda_policy_calculate_emsission"
  description = "IAM policy for Lambda function calculate_emsission"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.lambda_log_group.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_calculate_emsission" {
  policy_arn = aws_iam_policy.lambda_policy_calculate_emsission.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_policy" "ecr_policy" {
  name   = var.ecr_iam_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        ],
        "Resource": "*"
    }],
  })

  tags = merge(var.tags, {
    Name = "MyECRPolicy"
  })
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyECSExecutionRole"
  })
}

# Attach ECR policy to IAM role
resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
  policy_arn = aws_iam_policy.ecr_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}
