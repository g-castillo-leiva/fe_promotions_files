
terraform {

  backend "remote" {
    organization = "smu-chile"

    workspaces {
      prefix = "be_promotional_files-fargate-task-"
    }
  }

  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.56.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.13.0"
    }
  }
}

provider "consul" {
  scheme  = "https"
  address = var.consul_address
  token   = var.consul_token
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}