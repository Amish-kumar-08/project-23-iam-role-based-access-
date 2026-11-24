
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Create VPC
resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "project23-vpc-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# 2. Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "project23-public-subnet-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# 3. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name    = "project23-igw-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# 4. Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "project23-public-rt-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# 5. Associate Public Subnet with Route Table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Create Security Group
resource "aws_security_group" "project_sg" {
  name        = "project23-sg-amish"
  description = "SSH access for Project 23 EC2"
  vpc_id      = aws_vpc.project_vpc.id

  # Allow SSH only from your public IP
  ingress {
    description = "SSH access from Amish public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["20.197.25.80/32"]
  }

  # Allow outbound internet traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "project23-sg-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}


# ==========================================
# 7. S3 Bucket
# ==========================================

resource "aws_s3_bucket" "project_bucket" {
  bucket_prefix = "project23-amish-"

  tags = {
    Name    = "project23-s3-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# ==========================================
# 8. Block Public Access to S3
# ==========================================

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==========================================
# 9. Upload Test File to S3
# ==========================================

resource "aws_s3_object" "test_file" {
  bucket       = aws_s3_bucket.project_bucket.id
  key          = "test.txt"
  source       = "${path.module}/test.txt"
  content_type = "text/plain"

  etag = filemd5("${path.module}/test.txt")
}

# ==========================================
# 10. IAM Role Trust Policy
# ==========================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# ==========================================
# 11. Create IAM Role
# ==========================================

resource "aws_iam_role" "ec2_role" {
  name               = "project23-ec2-role-amish"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name    = "project23-ec2-role-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# ==========================================
# 12. Create Custom S3 Read-Only Policy
# ==========================================

resource "aws_iam_policy" "s3_read_policy" {
  name        = "project23-s3-read-policy-amish"
  description = "Read-only access to Project 23 S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.project_bucket.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.project_bucket.arn}/*"
      }
    ]
  })

  tags = {
    Name    = "project23-s3-read-policy-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# ==========================================
# 13. Attach Policy to IAM Role
# ==========================================

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# ==========================================
# 14. Create IAM Instance Profile
# ==========================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "project23-instance-profile-amish"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name    = "project23-instance-profile-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}


# ==========================================
# 15. Create EC2 Key Pair
# ==========================================

resource "aws_key_pair" "project_key" {
  key_name   = "project23-key-amish"
  public_key = file("${path.module}/project23-key-amish.pub")

  tags = {
    Name    = "project23-key-amish"
    Project = "Project23"
    Owner   = "Amish"
  }
}

# ==========================================
# 16. Create EC2 Instance
# ==========================================

resource "aws_instance" "project_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  key_name               = aws_key_pair.project_key.key_name

  # Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Assign public IP
  associate_public_ip_address = true

  # Require IMDSv2 for instance metadata
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Install AWS CLI for S3 testing
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y awscli
  EOF

  user_data_replace_on_change = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "project23-ec2-amish"
    Project = "Project23"
    Owner   = "Amish"
  }

  depends_on = [
    aws_iam_role_policy_attachment.s3_policy_attachment
  ]
}

# Allow EC2 to communicate with AWS Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_amish" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
