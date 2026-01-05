terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current"{
    
}


provider "aws" {
    region = var.aws_region
}

resource "aws_ecs_cluster" "consumer_cluster"{
    name = "consumer_cluster"
}

resource "aws_ecr_repository" "consumer_repo"{
    name = "consumer_repo"
}

