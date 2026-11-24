
output "vpc_id" {
  description = "Project 23 VPC ID"
  value       = aws_vpc.project_vpc.id
}

output "public_subnet_id" {
  description = "Project 23 public subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "internet_gateway_id" {
  description = "Project 23 Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "route_table_id" {
  description = "Project 23 public route table ID"
  value       = aws_route_table.public_rt.id
}

output "security_group_id" {
  description = "Project 23 security group ID"
  value       = aws_security_group.project_sg.id
}


output "s3_bucket_name" {
  value = aws_s3_bucket.project_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.project_bucket.arn
}

output "iam_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "iam_policy_arn" {
  value = aws_iam_policy.s3_read_policy.arn
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}



output "ec2_instance_id" {
  description = "Project 23 EC2 instance ID"
  value       = aws_instance.project_ec2.id
}

output "ec2_public_ip" {
  description = "Project 23 EC2 public IP"
  value       = aws_instance.project_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Project 23 EC2 public DNS"
  value       = aws_instance.project_ec2.public_dns
}

output "ec2_key_name" {
  description = "EC2 SSH key pair name"
  value       = aws_key_pair.project_key.key_name
}

