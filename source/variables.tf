variable "okta_org_name" {
  description = "Okta organization name. This information is show in the https://okta.com portal after login in. Example: `dev-12345678`."
  type        = string
}

variable "okta_api_token" {
  description = "Authentication token for Okta. You can generate an Okta API token in the Okta Developer Console. Follow these instructions: https://bit.ly/get-okta-api-token."
  type        = string
}

variable "region" {
  description = "AWS Region where resources will be deployed."
  type        = string
  default     = null
}

variable "name" {
  description = "Standard name to be used on all resources."
  type        = string
  default     = "okta-sso"
}

variable "vpc_cidr" {
  description = "CIDR Block for the new VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for Amazon EKS Cluster."
  type        = string
  default     = "1.30"
}

variable "admin_user_config" {
  description = "Configuration for Platform Admin Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "Platform"
    first_name = "Engineer"
    email      = "admin@example.com"
  }]
}

variable "user_config" {
  description = "Configuration for Developer Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "App1"
    first_name = "Developer"
    email      = "dev1@amazon.com"
    },
    {
      last_name  = "App2"
      first_name = "Developer"
      email      = "dev2@amazon.com"
    }
  ]
}
