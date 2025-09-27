terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-west-1"
}

# ------------------------------
# 1️⃣ ECR Repository
# ------------------------------
resource "aws_ecr_repository" "movie_rating" {
  name = "movie-rating"
}

# ------------------------------
# 2️⃣ Security Group
# ------------------------------
resource "aws_security_group" "movie_rating_sg" {
  name        = "movie-rating-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = "vpc-004137fec3f57c719" # Replace with your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 3️⃣ IAM Role for EC2
# ------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "movie-rating-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "movie-rating-ec2-ecr"
  role = aws_iam_role.ec2_role.name
}

# ------------------------------
# 4️⃣ EC2 Instance
# ------------------------------
resource "aws_instance" "movie_rating" {
  ami                         = "ami-0945610b37068d87a" # Amazon Linux 2023
  instance_type               = "t3.large"
  key_name                    = "movie-rating" # Replace with your key pair
  subnet_id                   = "subnet-0b01643545bffbdc8" # Replace with your subnet
  vpc_security_group_ids      = [aws_security_group.movie_rating_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y

              # Install Docker
              sudo dnf install -y docker
			  sudo systemctl enable docker
			  sudo systemctl start docker
			  
			  # Verify Docker is running
              sudo systemctl is-active docker 

              # Install AWS CLI v2
              sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              sudo unzip awscliv2.zip
              sudo ./aws/install

              # Login to ECR
              REGION="us-west-1"
              ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
              IMAGE_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/movie-rating:latest
              sudo aws ecr get-login-password --region $REGION | sudo docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

              # Pull and run Docker image
              IMAGE_URI="${var.image_uri}"
              sudo docker pull $IMAGE_URI
              sudo docker stop movie-rating || true
              sudo docker rm movie-rating || true
              sudo docker run -d --name movie-rating -p 8080:8080 $IMAGE_URI
              EOF

  tags = {
    Name = "movie-rating"
  }
}

# ------------------------------
# 5️⃣ CloudWatch Log Group
# ------------------------------
resource "aws_cloudwatch_log_group" "movie_rating" {
  name              = "/ec2/movie-rating/access"
  retention_in_days = 7
}
