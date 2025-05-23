################################################################################
# Base
################################################################################
provider "aws" {}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
data "aws_region" "current" {}

locals {
  region = coalesce(var.region, data.aws_region.current.name)

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    AWSSolution = "guidance-for-amazon-eks-integrations-with-external-sso-providers-on-aws"
    GithubRepo  = "https://github.com/aws-solutions-library-samples/"
  }
}

################################################################################
# IAM Roles
################################################################################

data "aws_iam_policy_document" "assume_role" {

  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "eks_developers" {
  name               = "${var.name}-developers"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "eks_operators" {
  name               = "${var.name}-operators"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
#--------------------------------------------------------------
# Adding guidance solution ID via AWS CloudFormation resource
#--------------------------------------------------------------
resource "aws_cloudformation_stack" "guidance_deployment_metrics" {
  name          = "tracking-stack"
  template_body = <<STACK
    {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "Guidance for Amazon EKS Integrations with external SSO Providers (SO9566)",
        "Resources": {
            "EmptyResource": {
                "Type": "AWS::CloudFormation::WaitConditionHandle"
            }
        }
    }
    STACK
}
