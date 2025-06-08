# EC2 Web Application Deployment using Terraform on AWS

This Terraform project provisions an EC2 instance on AWS to host a web application using Docker. It sets up the necessary network configurations, generates SSH key pairs, assigns security group rules, and optionally associates an Elastic IP.

# 📁 Directory Structure
```
.
├── app
│   ├── Dockerfile
│   ├── main.py
│   ├── README.md
│   └── requirements.txt
├── backend.tf
├── main.tf
├── modules
│   └── ec2
│       ├── ami.tf
│       ├── ec2.tf
│       ├── key-pair.tf
│       ├── network.tf
│       ├── outputs.tf
│       ├── provisioners.tf
│       └── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
├── ssh_key_pair
│   └── README.md
├── user_data.sh
└── variables.tf
```
---

## ⚙️ Prerequisites

1. Require **Terraform** >= 1.5
2. Required AWS IAM Permissions:
The IAM user running the terraform must have the following permissions:
    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "EC2ReadOnlyForTerraform",
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeImages",
                    "ec2:GetEbsDefaultKmsKeyId",
                    "ec2:DescribeVpcs",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeInstances",
                    "ec2:DescribeAddresses",
                    "ec2:DescribeAvailabilityZones",
                    "ec2:DescribeInstanceAttribute",
                    "ec2:RunInstances",
                    "ec2:TerminateInstances",
                    "ec2:CreateSecurityGroup",
                    "ec2:DeleteSecurityGroup",
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:AuthorizeSecurityGroupEgress",
                    "ec2:RevokeSecurityGroupIngress",
                    "ec2:RevokeSecurityGroupEgress",
                    "ec2:ImportKeyPair",
                    "ec2:CreateTags",
                    "ec2:AllocateAddress",
                    "ec2:AssociateAddress",
                    "ec2:ReleaseAddress",
                    "ec2:DescribeVpcAttribute",
                    "ec2:DescribeKeyPairs",
                    "ec2:DescribeSecurityGroupRules",
                    "ec2:DeleteKeyPair",
                    "ec2:DescribeInstanceTypes",
                    "ec2:DescribeTags",
                    "ec2:DescribeVolumes",
                    "ec2:DescribeInstanceCreditSpecifications",
                    "ec2:DescribeAddressesAttribute",
                    "ec2:DisassociateAddress"
                ],
                "Resource": "*"
            }
        ]
    }
    ```
    **Recommended:** You can also attach the **AdministratorAccess** policy to the IAM user during setup.

3. **AWS CLI** installed and configured with a user having sufficient IAM permissions mentioned above.

    Option 1: Using AWS CLI configuration:-
    ```
    aws configure 
    ```
    Option 2: Using Environment Variables
    Set the following environment variables in your terminal session:-
    ```
    export AWS_ACCESS_KEY_ID=your_access_key
    export AWS_SECRET_ACCESS_KEY=your_secret_key
    export AWS_DEFAULT_REGION=your_region
    ```

## 🔧 Configuration Variables

Customize the behavior of the Terraform module using the following input variables:

| Variable Name           | Description                                                                                                                                       | Type                | Required | Default Value             |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|----------|----------------------------|
| `ami_name`              | AMI name pattern to filter for the latest Ubuntu 22.04 image. Change this if you want a different Linux distribution.                            | `string`            | No       | `ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*` |
| `vpc_id`                | Optional VPC ID to launch the EC2 instance in. If provided, `subnet_id` must also be set.                                                        | `string`            | No       | `""`                       |
| `subnet_id`             | Optional subnet ID within the specified VPC. Required only when `vpc_id` is set.                                                                  | `string`            | No       | `""`                       |
| `instance_type`         | EC2 instance type to launch (e.g., `t3.micro`, `t3.small`).                                                                                       | `string`            | No       | `"t3.small"`               |
| `sg_ingress_rule`       | Map of ingress rules for the security group. Each rule should define keys: `description`, `cidr_ipv4`, `ip_protocol`, `from_port`, `to_port`.   | `map(map(string))`  | No       | SSH (22) and Web (8081) rules |
| `enable_eip`            | Set to `true` to create and associate an Elastic IP with the instance.                                                                           | `bool`              | No       | `false`                    |
| `instance_name`         | Name tag for the EC2 instance.                                                                                                                    | `string`            | No       | `"devops-assignment"`      |
| `sg_name`               | Name for the security group.                                                                                                                      | `string`            | No       | `"devops-assignment-sg"`   |
| `key_pair_name`         | Name of the existing AWS SSH Key Pair to use for connecting to the EC2 instance.                                                                 | `string`            | No       | `"devops-assignment-key"`  |
| `user_data_file_path`   | Path to the user-data shell script file to execute during instance launch.                                                                       | `string`            | No       | `"user_data.sh"`           |
| `priv_key_output_path`  | Local path where the generated private key should be saved.                                                                                       | `string`            | No       | `"ssh_key_pair/"`          |
| `web_app_dir_path`      | Local path to the application directory that should be copied to the instance.                                                                   | `string`            | No       | `"app"`                    |


ℹ️ **Note:** The `ami_name` is set to fetch the most recent Ubuntu 22.04 `amd64` AMI from the region specified in the `region` variable. It is strongly recommended to use this distribution to ensure compatibility with the commands provided in the `user_data.sh` script.



## 📌 Variable Dependencies & Validation Notes

The following dependencies and conditions apply to ensure successful Terraform execution:

### ✅ Required Files and Directories

| Path/Variable             | Requirement                                                                 |
|---------------------------|------------------------------------------------------------------------------|
| `user_data`               | File must exist and contain valid shell script content.                     |
| `priv_key_output_path`    | Directory must exist locally to save the generated private key file.        |
| `web_app_dir_path`        | Directory must exist and contain the web application code (no trailing `/`).|

---

### 🔄 Variable Relationship Dependencies

| Dependency Logic                                                                                             | Explanation                                                                                     |
|-------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| `vpc_id != ""` → `subnet_id` must also be provided                                                           | If a custom VPC is specified, a public subnet in that VPC is also required.                    |
| `sg_ingress_rule` must include at least required rules (SSH, Web ports)                                      | Ensure correct port configuration for application and remote access.                           |
| `user_data` script should be formatted properly and contain necessary installation or setup commands         | This script runs during EC2 boot and often sets up the application environment.                |
| If `enable_eip = true`, EC2 must be launched in a public subnet with an internet gateway attached            | Elastic IPs only work with public networking.                                                  |

---

## 📄 Using terraform.tfvars

You can create and use **terraform.tfvars** in the root of your project to define input variables. For e.g.

```
region               = "ap-south-1"
ami_name             = "ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"
vpc_id               = "vpc-012397139173"
subnect_id           = "sub-123123asda12"
sg_ingress_rule = {
    ssh_rule = {
        description = "Allow SSH port"
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
    },
    web_rule = {
        description = "Allow Web traffic"
        from_port   = 8081
        to_port     = 8081
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
    }
}
instance_type        = "t3.small"
enable_eip           = false
instance_name        = "devops-assignment"
sg_name              = "devops-assignment-sg"
key_pair_name        = "devops-assignment-key"
user_data_file_path  = "user_data.sh"
priv_key_output_path = "ssh_key_pair/"
web_app_dir_path     = "app"
```
---

## ⚙️ Terraform Backend Configuration

This project uses the local backend by default for storing the state file, which is fine for testing.
For production, you should use an S3 backend with state locking via DynamoDB.
To enable it, uncomment and update the backend block in **backend.tf**.

Important:

- Ensure the S3 bucket and DynamoDB table for state locking exist before initializing Terraform.
- You must have sufficient permissions to access both the S3 bucket and DynamoDB table.
- Update the values like bucket name, key and dynamodb_table name as per the requirments.

For more details on IAM permissions, see the official docs:
https://developer.hashicorp.com/terraform/language/backend/s3#s3-bucket-permissions

## Usage

1. Clone the repository:
    ```
    git clone <repository-url>
    cd <repository-directory>
    ```
2. Initialize Terraform:
    ```
    terraform init
    ```
3. Review the execution plan:
    ```
    terraform plan
    ```
4. Apply the configuration:
    ```
    terraform apply
    ```