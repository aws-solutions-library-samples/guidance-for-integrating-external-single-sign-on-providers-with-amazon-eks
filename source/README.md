# Okta Single Sign-On for Amazon EKS Cluster

This code demonstrates how to deploy an Amazon EKS cluster, integrated with Okta as an the Identity Provider (IdP) for Single Sign-On (SSO) authentication. The configuration for authorization is done using Kubernetes Role-based access control (RBAC).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |
| <a name="requirement_okta"></a> [okta](#requirement\_okta) | ~> 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.66.0 |
| <a name="provider_okta"></a> [okta](#provider\_okta) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.24 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.eks_developers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_operators](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [okta_app_group_assignments.eks](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/app_group_assignments) | resource |
| [okta_app_oauth.eks](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/app_oauth) | resource |
| [okta_auth_server.eks](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/auth_server) | resource |
| [okta_auth_server_claim.eks_groups](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/auth_server_claim) | resource |
| [okta_auth_server_policy.eks](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/auth_server_policy) | resource |
| [okta_auth_server_policy_rule.auth_code](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/auth_server_policy_rule) | resource |
| [okta_group.developers](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/group) | resource |
| [okta_group.operators](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/group) | resource |
| [okta_group_memberships.developers](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/group_memberships) | resource |
| [okta_group_memberships.operators](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/group_memberships) | resource |
| [okta_user.admin](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/user) | resource |
| [okta_user.user](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/user) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_config"></a> [admin\_user\_config](#input\_admin\_user\_config) | Configuration for Platform Admin Users. | <pre>list(object({<br>    last_name  = string<br>    first_name = string<br>    email      = string<br>  }))</pre> | <pre>[<br>  {<br>    "email": "admin@example.com",<br>    "first_name": "Engineer",<br>    "last_name": "Platform"<br>  }<br>]</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for Amazon EKS Cluster. | `string` | `"1.30"` | no |
| <a name="input_name"></a> [name](#input\_name) | Standard name to be used as prefix on all resources. | `string` | `"okta-sso"` | no |
| <a name="input_okta_api_token"></a> [okta\_api\_token](#input\_okta\_api\_token) | Authentication token for Okta. You can generate an Okta API token in the Okta Developer Console. Follow these instructions: https://bit.ly/get-okta-api-token. | `string` | n/a | yes |
| <a name="input_okta_org_name"></a> [okta\_org\_name](#input\_okta\_org\_name) | Okta organization name. This information is show in the https://okta.com portal after login in. Example: `dev-12345678`. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where resources will be deployed. | `string` | `null` | no |
| <a name="input_user_config"></a> [user\_config](#input\_user\_config) | Configuration for Developer Users. | <pre>list(object({<br>    last_name  = string<br>    first_name = string<br>    email      = string<br>  }))</pre> | <pre>[<br>  {<br>    "email": "dev1@amazon.com",<br>    "first_name": "Developer",<br>    "last_name": "App1"<br>  },<br>  {<br>    "email": "dev2@amazon.com",<br>    "first_name": "Developer",<br>    "last_name": "App2"<br>  }<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR Block for the new VPC. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubeconfig"></a> [configure\_kubeconfig](#output\_configure\_kubeconfig) | Update kubeconfig with OKTA OIDC parameters. |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks"></a> [eks](#output\_eks) | Amazon EKS Cluster full configuration |
| <a name="output_okta_login"></a> [okta\_login](#output\_okta\_login) | Setup OIDC Login for OKTA. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | Amazon VPC full configuration |
