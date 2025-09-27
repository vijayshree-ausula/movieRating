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
data "aws_ecr_repository" "movie_rating" {
  name = "movie-rating"
}

# ------------------------------
# 2️⃣ Security Group
# ------------------------------
data "aws_security_group" "movie_rating_sg" {
  id = "sg-0fb3ea68dfd79b75f" # existing SG ID
}

# ------------------------------
# 3️⃣ IAM Role for EC2
# ------------------------------
data "aws_iam_role" "ec2_role" {
  name = "movie-rating-ec2-role"
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
data "aws_cloudwatch_log_group" "movie_rating" {
  name = "/ec2/movie-rating/access"
}
