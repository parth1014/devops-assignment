# Define terraform s3 backend

# terraform {
#   backend "s3" {
#     bucket         = "<your-terraform-state-bucket-name>"
#     key            = "terraform.tfstate"  # path within the bucket
#     region         = "ap-south-1"                 # adjust based on your deployment
#     dynamodb_table = "<your-lock-table>"            # for state locking (recommended)
#     encrypt        = true
#   }
# }
