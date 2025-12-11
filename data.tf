provider "aws"  {
  region  = "ap-southeast-2"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
}

data "aws_caller_identity" "main" {}
data "aws_region" "main" {}
