# Required terraform providers with specific versions to ensure consistent behavior.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

# AWS region to deploy the resources in.
# Default is set to Asia Pacific (Mumbai).
variable "region" {
  type    = string
  default = "ap-south-1"
}

# Configure the AWS provider with the given region.
provider "aws" {
  region = var.region
}