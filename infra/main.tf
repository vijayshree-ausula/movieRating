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
data "aws_iam_instance_profile" "ec2_profile" {
  name = "movie-rating-ec2-ecr"
}

# Reference your already allocated EIP
data "aws_eip" "existing_eip" {
  id = "eipalloc-00061aeaf66469108"  # replace with your EIP Allocation ID
}

# ------------------------------
# 4️⃣ EC2 Instance
# ------------------------------
resource "aws_instance" "movie_rating" {
  #ami                         = "ami-0945610b37068d87a" # Amazon Linux 2023
  ami                         = "ami-00142eb1747a493d9" # Amazon Linux 2023 kernel-6.1 AMI
  instance_type               = "t2.micro"
  key_name                    = "movie-rating" # Replace with your key pair
  subnet_id                   = "subnet-0b01643545bffbdc8" # Replace with your subnet
  vpc_security_group_ids      = [data.aws_security_group.movie_rating_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
  #!/bin/bash
  set -euxo pipefail
  exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
  # Wait for network to be ready
  until ping -c1 amazon.com &>/dev/null; do
    echo "Waiting for network..."
    sleep 5
  done
              
  dnf update -y
 
  dnf install -y docker
			  
  # Enable and start Docker
  systemctl enable docker
  systemctl start docker
			  
  # Verify Docker is running
  systemctl is-active docker 
              
  # Add ec2-user to docker group
  usermod -aG docker ec2-user

  # Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install

  # Login to ECR
  REGION="us-west-1"
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  IMAGE_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/movie-rating:latest
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

  # Pull and run Docker image
  docker pull $IMAGE_URI
  docker stop movie-rating || true
  docker rm movie-rating || true

  # Create log directory on host
  mkdir -p /var/log/tomcat
  touch /var/log/tomcat/access.log
  chown ec2-user:ec2-user /var/log/tomcat/access.log
  sudo chmod 755 /var/log/tomcat/access.log
            
  # Install CloudWatch Agent
  dnf install -y amazon-cloudwatch-agent

  # Write CloudWatch Agent config
  cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWCONF
  {
      "agent": {
            "metrics_collection_interval": 60,
            "run_as_user": "ec2-user"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/tomcat/access.log",
                "log_group_name": "/ec2/movie-rating/access",
                "log_stream_name": "movie-rating-access",
                "timezone": "UTC"
              }
            ]
          }
       }
    }
  }
  CWCONF

  # Start CloudWatch Agent with config
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
      -s
      
  systemctl enable amazon-cloudwatch-agent
  systemctl start amazon-cloudwatch-agent

  docker run -d --name movie-rating --restart unless-stopped -p 8080:8080 -v /var/log/tomcat:/var/log/tomcat $IMAGE_URI
  EOF

  tags = {
    Name = "movie-rating"
  }
}

resource "aws_eip_association" "movie_rating_eip_assoc" {
  instance_id   = aws_instance.movie_rating.id
  allocation_id = data.aws_eip.existing_eip.id
}

# ------------------------------
# 5️⃣ CloudWatch Log Group
# ------------------------------
data "aws_cloudwatch_log_group" "movie_rating" {
  name = "/ec2/movie-rating/access"
}
