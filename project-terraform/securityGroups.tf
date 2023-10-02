resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_instance_sg"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = merge(var.tags, {
    Name    = "Private_Security_Group"
  })
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda"
  vpc_id      = aws_vpc.my_vpc.id

ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Define your security group rules here
  # Example rule: allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define security group for Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name_prefix = var.sg_name_alb
  vpc_id      = aws_vpc.my_vpc.id

  # Allow incoming HTTP, HTTPS, SSH, and custom ports
  # ingress {
  #   from_port   = var.http_port
  #   to_port     = var.http_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = var.custom_port_2
  #   to_port     = var.custom_port_2
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = var.https_port
  #   to_port     = var.https_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = var.custom_port_1
  #   to_port     = var.custom_port_1
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = var.ssh_port
  #   to_port     = var.ssh_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
 ingress{
    description = "Ingress rule for SSH"
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow SSH outbound traffic (replace with your public IP)
  egress {
    description = "Ingress rule for SSH"
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "MyALBSecurityGroup"
  })
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = var.sg_name_ecs
  vpc_id      = aws_vpc.my_vpc.id

  # # Allow incoming SSH, HTTP, HTTPS, and custom ports
  # ingress {
  #   from_port   = var.ssh_port
  #   to_port     = var.ssh_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = [var.all_cidr]
  # }

  # ingress {
  #   from_port   = var.http_port
  #   to_port     = var.http_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = var.https_port
  #   to_port     = var.https_port
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = var.custom_port_1
  #   to_port     = var.custom_port_1
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = var.custom_port_2
  #   to_port     = var.custom_port_2
  #   protocol    = var.protocol_tcp
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
 ingress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "MyECSSecurityGroup"
  })
}