# Project 23: IAM Role-Based Access Using Terraform

## 📌 Project Overview

**Description:** Implemented IAM Role-Based Access for an Amazon EC2 instance to securely access an Amazon S3 bucket without storing static AWS access keys on the EC2 instance.

Used Terraform to automate the creation of AWS infrastructure, including a custom VPC, public subnet, Internet Gateway, security group, S3 bucket, IAM role, IAM policies, instance profile, and EC2 instance.

Attached a custom S3 read-only IAM policy to the EC2 role, allowing the instance to list and download S3 objects while explicitly restricting upload and delete operations.

Used AWS Systems Manager Run Command to execute commands remotely on the EC2 instance and verify IAM role authentication and S3 permissions.

**GitHub Repository:** [Paste GitHub URL]

## 🎯 Project Objectives

- Understand IAM roles and instance profiles.
- Allow EC2 instances to access AWS services securely.
- Avoid storing static AWS access keys on EC2.
- Implement least-privilege IAM permissions.
- Allow S3 bucket listing and object downloads.
- Deny S3 object uploads and deletions.
- Automate AWS infrastructure using Terraform.
- Verify IAM permissions using AWS CLI and Systems Manager.

## 🏗️ Architecture

The project follows this architecture:

```text
                 AWS Cloud
                     |
              Custom VPC
              10.23.0.0/16
                     |
               Public Subnet
               10.23.1.0/24
                     |
                EC2 Instance
              project23-ec2-amish
                     |
              IAM Instance Profile
                     |
              IAM Role
       project23-ec2-role-amish
                     |
          S3 Read-Only IAM Policy
                     |
               Amazon S3
                     |
          project23-amish-bucket

       Allowed Operations:
       ✓ ListBucket
       ✓ GetObject

       Denied Operations:
       ✗ PutObject
       ✗ DeleteObject
```

## 🛠️ Technologies Used

- AWS EC2
- Amazon S3
- AWS IAM
- AWS Systems Manager (SSM)
- AWS CLI
- Terraform
- Ubuntu 24.04
- Linux

## ☁️ AWS Resources Created

| Resource | Name |
|---|---|
| VPC | `project23-vpc-amish` |
| Public Subnet | `project23-public-subnet-amish` |
| Internet Gateway | `project23-igw-amish` |
| Route Table | `project23-public-rt-amish` |
| Security Group | `project23-sg-amish` |
| S3 Bucket | `project23-amish-cc4344195f55490d1e1e66e6a9` |
| IAM Role | `project23-ec2-role-amish` |
| IAM Policy | `project23-s3-read-policy-amish` |
| Instance Profile | `project23-instance-profile-amish` |
| EC2 Instance | `project23-ec2-amish` |
| EC2 Key Pair | `project23-key-amish` |

**AWS Region:** `ap-south-1` (Mumbai)

**EC2 Instance Type:** `t3.micro`

**Operating System:** Ubuntu Server 24.04 LTS

## 🔐 IAM Policy Configuration

Created a custom IAM policy that grants the EC2 instance read-only access to the designated S3 bucket.

### Allowed Permissions

| IAM Action | Description |
|---|---|
| `s3:ListBucket` | List objects inside the S3 bucket |
| `s3:GetObject` | Download objects from the S3 bucket |

### Restricted Permissions

| IAM Action | Description |
|---|---|
| `s3:PutObject` | Upload objects to the bucket |
| `s3:DeleteObject` | Delete objects from the bucket |

The IAM role also has the AWS-managed `AmazonSSMManagedInstanceCore` policy attached to support Systems Manager management.

## ⚙️ Implementation Steps

### 1. Created AWS Infrastructure Using Terraform

Used Terraform to provision:

- Custom VPC and public subnet.
- Internet Gateway and public route table.
- Security group with restricted SSH access.
- Amazon S3 bucket with public access blocked.
- EC2 instance and key pair.

### 2. Created IAM Role and Policy

Created an IAM role with EC2 as its trusted service.

Attached the custom S3 read-only policy to the role and associated the role with an EC2 instance profile.

Also attached `AmazonSSMManagedInstanceCore` for Systems Manager connectivity.

### 3. Launched EC2 Instance

Launched an Ubuntu EC2 instance in the custom public subnet and attached the IAM instance profile.

### 4. Installed AWS CLI

Installed AWS CLI v2 on the EC2 instance using AWS Systems Manager Run Command.

No static AWS access keys were configured on the EC2 instance.

### 5. Verified IAM Role Authentication

Executed:

```bash
aws sts get-caller-identity
```

Verified that the EC2 instance authenticated using the assumed IAM role:

```text
arn:aws:sts::590507089733:assumed-role/project23-ec2-role-amish/i-04dfdc36e5b8f1f89
```

### 6. Tested S3 Read Permissions

Listed objects in the S3 bucket:

```bash
aws s3 ls s3://project23-amish-cc4344195f55490d1e1e66e6a9/
```

Downloaded the test object:

```bash
aws s3 cp s3://project23-amish-cc4344195f55490d1e1e66e6a9/test.txt /tmp/project23-test.txt
```

Verified its contents:

```bash
cat /tmp/project23-test.txt
```

Output:

```text
Hello from Project 23 - IAM Role Based Access by Amish!
```

### 7. Tested S3 Upload Restriction

Attempted to upload an object to the S3 bucket.

AWS returned:

```text
AccessDenied

not authorized to perform: s3:PutObject
```

Confirmed that the upload operation was denied by the IAM policy.

### 8. Tested S3 Delete Restriction

Attempted to delete the existing `test.txt` object.

AWS returned:

```text
AccessDenied

not authorized to perform: s3:DeleteObject
```

Confirmed that the delete operation was denied by the IAM policy.

## ✅ Verification Results

| Test Case | Expected Result | Actual Result |
|---|---|---|
| EC2 IAM role authentication | Success | Passed |
| S3 bucket listing | Allowed | Passed |
| S3 object download | Allowed | Passed |
| S3 object upload | Denied | Passed |
| S3 object deletion | Denied | Passed |

All five permission and authentication tests passed.

## 📸 Project Screenshots

Screenshots documenting the implementation and verification results are available in the `screenshots/` directory.

| Screenshot | Description |
|---|---|
| `01-ec2-instance.png` | EC2 instance details |
| `02-iam-role-policy.png` | IAM role and attached policies |
| `03-ec2-role-identity.png` | EC2 assumed-role identity |
| `04-s3-download-success.png` | S3 listing and download success |
| `05-s3-upload-denied.png` | S3 upload denied |
| `06-s3-delete-denied.png` | S3 deletion denied |

## 📂 Project Structure

```text
project-23-iam-role-based-access/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
├── README.md
│
└── screenshots/
    ├── 01-ec2-instance.png
    ├── 02-iam-role-policy.png
    ├── 03-ec2-role-identity.png
    ├── 04-s3-download-success.png
    ├── 05-s3-upload-denied.png
    └── 06-s3-delete-denied.png
```

## 🚀 Terraform Deployment

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

View Terraform outputs:

```bash
terraform output
```

## 🧹 Resource Cleanup

After completing the project and saving the required screenshots, destroy the resources managed by this project's Terraform state:

```bash
terraform destroy
```

Review the destruction plan before confirming.

**Important:** Ensure that the Terraform state belongs only to this project. Do not destroy resources belonging to other projects or users.

## 🔒 Security Considerations

- Used IAM roles instead of storing static AWS access keys on EC2.
- Followed the principle of least privilege.
- Restricted S3 access to the required bucket.
- Allowed only read operations on S3 objects.
- Blocked public access to the S3 bucket.
- Restricted SSH access to a specific public IP address.
- Kept the EC2 private key out of GitHub.
- Used Systems Manager Run Command for remote administration.

## 📚 Key Learnings

Through this project, I learned:

- How IAM roles provide temporary credentials to EC2 instances.
- How instance profiles associate IAM roles with EC2.
- How to implement least-privilege IAM policies.
- How to control S3 access using IAM permissions.
- How to use AWS Systems Manager Run Command.
- How to automate AWS infrastructure using Terraform.
- How to verify allowed and denied AWS API operations.

## 🏁 Conclusion

Successfully implemented an IAM Role-Based Access solution using Terraform.

The EC2 instance accessed Amazon S3 through its attached IAM role without requiring static AWS access keys. Read operations such as listing and downloading objects were successful, while upload and delete operations were denied.

This project demonstrates secure AWS service-to-service access using IAM roles and the principle of least privilege.
