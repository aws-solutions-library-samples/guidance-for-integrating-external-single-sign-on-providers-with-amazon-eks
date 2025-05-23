# Guidance for Amazon EKS Integrations with external SSO Providers

## Table of Contents

- [Guidance for Amazon EKS Integrations with external SSO Providers](#guidance-for-amazon-eks-integrations-with-external-sso-providers)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Architecture and Workflow](#architecture-and-workflow)
    - [AWS Services in this guidance](#aws-services-in-this-guidance)
    - [Cost](#cost)
    - [Sample Cost Table](#sample-cost-table)
  - [Security](#security)
  - [Prerequisites](#prerequisites)
    - [Operating System](#operating-system)
    - [Third-party tools](#third-party-tools)
    - [AWS account requirements](#aws-account-requirements)
    - [Supported AWS Regions](#supported-aws-regions)
  - [Deployment Steps](#deployment-steps)
  - [Deployment Validation](#deployment-validation)
  - [Cleanup](#cleanup)
  - [Next Steps](#next-steps)
  - [Notices](#notices)
  - [Appendix](#appendix)
    - [Comparison table between SAML and OIDC Connect with Okta SSO](#comparison-table-between-saml-and-oidc-connect-with-okta-sso)
  - [Authors](#authors)

## Overview

- Many enterprise AWS customers are using 3rd party Single Sign-On (SSO) authentication providers to integrate their AWS EKS cluster authentication with those providers for consistent application security posture
- This guidance demonstrates how to automate deployment of a [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) into the AWS Cloud and its integration with various Identity Providers (IdPs) for Single Sign-On (SSO) authentication using [Terraform](https://www.hashicorp.com/products/terraform) based blueprint. The configuration for authorization is implemented using Kubernetes Role-based access control (RBAC).

### Architecture and Workflow

![Architecture Diagram](./assets/images/integrating-external-single-sign-on-providers-with-amazon-eks.png)

Figure 1. Amazon EKS Integrations with external SSO Providers - Reference Architecture
</div>

1. Platform Engineer commits and pushes [Terraform](https://www.hashicorp.com/products/terraform) Infrastructure as Code (IaC) changes to project GitHub [repository](https://github.com/aws-solutions-library-samples/guidance-for-integrating-external-single-sign-on-providers-with-amazon-eks).
2. A Terraform infrastructure provisioning workflow is invoked by the code push to the Git repository or is initiated manually by Platform Engineer.
3. The Terraform infrastructure provisioning workflow starts resource deployment processes, targeting AWS and [Okta](https://www.okta.com/) environments.
4. Required [Amazon Identity and Access Management (IAM)](https://aws.amazon.com/iam/) Roles, Polices and [Key Management Service (KMS)](https://aws.amazon.com/kms/) keys are created.
5. [Amazon Virtual Private Cloud (Amazon VPC)](https://aws.amazon.com/vpc/) environments for [Amazon Elastic Kubernetes Service (Amazon EKS)](https://aws.amazon.com/eks/) control plane and related networking components are deployed.
6. [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) cluster control plane is deployed into EKS Virtual Provate Cloud (VPC).The cluster control plane is provisioned across multiple Availability Zones (AZs) and fronted by [Network Load Balancing (NLB)](https://aws.amazon.com/elasticloadbalancing/network-load-balancer/)
7. Your VPC for Amazon EKS Compute Plane is deployed with public and private subnets and other networking components across multiple AZs.
8. Amazon EKS data plane with [Managed Node Groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) containing [Amazon Elastic Compute Cloud (Amazon EC2)](https://aws-preview.aka.amazon.com/ec2/) compute nodes are deployed into your VPC.
9. Okta resources, OAuth server, users, groups, and role assignments are created in the specified [Okta organization](https://developer.okta.com/docs/concepts/okta-organizations/).
10. An integration between Amazon EKS and Okta SSO is created, along with required [Kubernetes Roles and RoleBidindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).
11. The Amazon EKS Cluster is available for applications and end users, its Kubernetes API is accessible via [Network Load Balancer (NLB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) with Okta SSO user authentication

### AWS Services in this guidance

| **AWS service**  | Role | Description |
|-----------|------------|-------------|
| [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/)| Core service |  EKS service is used to host the Karmada solution that uses containers. In essence it is an extension of the Kubernetes API.|
| [Amazon Elastic Compute Cloud (EC2)](https://aws.amazon.com/ec2/)| Core service | EC2 service is used as the host of the containers needed for this solution.|
| [Amazon Virtual Private Cloud - VPC](https://aws.amazon.com/vpc/)| Core Service | Network security layer |
| [Amazon Elastic Conatiner Registry - ECR](http://aws.amazon.com/ecr/) | Supporting service | Used for storing container images required by the runtimes. |
| [Amazon Network Load Balancer (NLB)](https://aws.amazon.com/elasticloadbalancing/network-load-balancer/)|Supporting service | The NLB  is the entry point to interact with the K8s API server|
| [Amazon Elastic Block Store (EBS)](https://aws.amazon.com/ebs)|Supporting service | Encrypted EBS volumes are used by the Karmada etcd database attached to compute nodes/EC2 instances to keep its state and consistency. All state changes and updates get persisted in EBS volumes across all EC2 compute nodes that host etcd pods.|
| [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/)|Supporting service |  AWS IAM service is used for the creation of an IAM user with adequate permissions to create and delete Amazon EKS clusters access.|
| [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/)|Supporting service |  AWS KMS is responsible for managing encryption keys that can be applied to several resouces, making sure to protect data at rest. Some examples of encrypted resources on this solution are Amazon EBS volumes, and Amazon EKS Clusters.|

### Cost

You are responsible for the cost of the AWS services used while running this Guidance. As of October, 2024 , the cost for running this Guidance with the default settings in the `us-east-1` Region (US East (N. Virginia)) is approximately **$235.06-$459.95 per month**.

We recommend creating a [Budget](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html) through [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) to help manage costs. Prices are subject to change. For full details, refer to the pricing webpage for each AWS service used in this Guidance.

### Sample Cost Table

<!-- The following table provides a sample cost breakdown for deploying this guidance with the default parameters in the US East (N. Virginia) `us-east-1` Region for one month.-->

The following sample table provides a sample cost breakdown for deploying this guidance with 3 Amazon EKS clusters (one Karmada control plane and 2 managed clusters)
in the US-East-1 `us-east-1` region for one month. The AWS cost calculator is available [here](https://calculator.aws/#/estimate?id=03fdada5a7299a7b70c51a6c9b0037cd0117cbfc).
Please that cost calculations are based on the default configuration options of the [End-to-end, fully automated](#deployment-steps) guidance deployment method described below.

| **AWS service**  | Dimensions | Cost, month \[USD\] |
|-----------|------------|------------|
| Amazon EKS  | 1 Cluster | \$ 73 |
| Amazon EC2  | 2-5 Nodes on the Managed Node Group | \$ 125.56-$ 350.45 |
| VPC | 1 VPC, 1 NAT Gateway, 1 Public IPv4 | \$ 36.50 |
| **TOTAL estimate** |  | **\$ 235.06-$ 459.95** |

## Security

When you build systems on AWS infrastructure, security responsibilities are shared between you and AWS. This [shared responsibility model](https://aws.amazon.com/compliance/shared-responsibility-model/) reduces your operational burden because AWS operates, manages, and controls the components including the host operating system, the virtualization layer, and the physical security of the facilities in which the services operate. For more information about AWS security visit [AWS Cloud Security](http://aws.amazon.com/security/).

This guidance relies on a several reasonable default options and "principle of least privilege" access for all resources, being it's main goal to control an manage users and groups access to Amazon EKS clusters. Relying on [Okta](https://www.okta.com/) as the Single Sign-On (SSO) option for the authentication side and Kubernetes Native [Role-based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) for the authotization side, only authenticated users be able to login into to the cluster, and the level of access within it can be very granular to specific actions on specific resources.

On the infrastructure security side, [AWS Bottlerocket](https://aws.amazon.com/bottlerocket/?amazon-bottlerocket-whats-new&amazon-bottlerocket-whats-new.sort-by=item.additionalFields.postDateTime&amazon-bottlerocket-whats-new.sort-order=desc), a minimal footprint operating system specifically designed to work with container orchestrators is used for conatiner host operational system, reducing the surface area of attacks by disabling SSH access, and enforcicing [SELinux](https://selinuxproject.org/page/Main_Page) by default.

The guidance also ensures data protection with encryption enabled on Amazon EKS at the cluster level, together with all EC2 instances volumes encrypted during the node creation time using Amazon KMS, making sure that all data is encrypted by default. The Amazon EKS encryption configuration enables envelope encryption of Kubernetes secrets using KMS as well.

## Prerequisites

### Operating System

This solution relies on [AWS Bottlerocket](https://aws.amazon.com/bottlerocket/?amazon-bottlerocket-whats-new&amazon-bottlerocket-whats-new.sort-by=item.additionalFields.postDateTime&amazon-bottlerocket-whats-new.sort-order=desc) as the Operational System on the Amazon EKS worker nodes. It keeps three primary goals: **Minimal** - **Safe Updates** - **Security Focused**.

Bottlerocket is a Linux-based operating system optimized for hosting containers. It’s free and open-source software, developed in the open on GitHub. Bottlerocket is installed as the base operating system on the data plane side of the Amazon EKS clusters, where your containers are running. It is specifically designed to work with container orchestrator, suchas Kubernetes, to automate the lifecycle of the containers running in your cluster.

Because it is API driven, Bottlerocket comes ready to be used with Amazon EKS without any additional packages or requirements, being an out-of-the-box OS image already compliant with **[CIS Benchmark Level 1](https://aws.amazon.com/what-is/cis-benchmarks/)**.

### Third-party tools

[Okta Single Sign-On](https://www.okta.com/products/single-sign-on-customer-identity/) is the main third-party software deployed as part of this solution. Okta SSO management platform provides control, security, and easy management portal where users can simply log in once and use all accessible resources.

### AWS account requirements

This guidance requires you to have an active AWS account. The required AWS resources will be deployed via Terraform.

### Supported AWS Regions

The AWS services used for this guidance are supported in all AWS regions at this time.

## Deployment Steps

1. Clone the repo using command.

   ```sh
   git clone https://github.com/aws-solutions-library-samples/guidance-for-amazon-eks-integrations-with-external-sso-providers-on-aws/
   ```

2. Go to the Terraform code folder.

   ```sh
   cd guidance-for-amazon-eks-integrations-with-external-sso-providers-on-aws/source
   ```

3. Adjust any required variables on the `variables.tf` file or creating a `.tfvars` file.
4. Edit the `okta.tf` file to insert values for your Okta organization and token. Actually, those values can be entered in the `variables.tf` as well as shown below:

   ```sh
    variable "okta_org_name" {
       description = "Okta organization name. This information is show in the https://okta.com portal after login in. Example: `dev-12345678`."
       type        = string
       default     = "dev-587496XX"
     }

   variable "okta_api_token" {
       description = "Authentication token for Okta. You can generate an Okta API token in the Okta Developer Console. Follow these instructions: https://bit.ly/get-okta-api-token."
       type        = string
       default     = "00xQ1suYg5wlhCPRR7v_XXXXXXXXXXXXXXXXXX"
    }
    ```

5. Initialize Terraform providers.

   ```sh
   terraform init
   ```

6. Plan/validate your Terraform deployment.

   ```sh
   terraform plan
   ```

7. Apply the Terraform code, using a targeted approach

   ```sh
   terraform apply -target module.vpc -auto-approve
   terraform apply -target module.eks -auto-approve
   terraform apply -auto-approve
   ```

It is always recommended to monitor an output of Terraform code for possible errors and other messages from provisoners

## Deployment Validation

1. After the `terraform` commands are executed successfully, check if the newly created users are active.

    To do that use the link provided in the email invite if you added a valid email address for your users, or go to the [Okta Admin Dashboard](https://dev-ORGID-admin.okta.com/admin/users/), select the user, and click on *Set Password and Activate* button.

    ![Set Okta User Password](./assets/images/okta_user_set_password.jpg)

    Figure 2. Set Password and Activate OKTA user

2. With the active users, use the `terraform output` example to setup your `kubeconfig` profile to authenticate through Okta using `Authentication server issuer URL` and `ClientID`. You can also find out those values from Okta web console as shown below:

    ![Okta Authentication Server URL](./assets/images/okta_api_authorization_server.jpg)

    ```sh
    configure_kubeconfig = <<EOT
        kubectl config set-credentials oidc \
        --exec-api-version=client.authentication.k8s.io/v1beta1 \
        --exec-command=kubectl \
        --exec-arg=oidc-login \
        --exec-arg=get-token \
        --exec-arg=--oidc-issuer-url=https://dev-ORGID.okta.com/oauth2/XXXXXXXXXXXXXXXXXX \
        --exec-arg=--oidc-client-id=XXXXXXXXXXXXXXXXXX
        --exec-arg=--oidc-extra-scope="email offline_access profile openid"
    ```

    Running that file should open a browser window that provides an Okta authentication UI.

3. With the `kubeconfig` configured, you'll be able to run `kubectl` commands in your Amazon EKS Cluster using the `--user` cli option to impersonate the Okta authenticated user. When `kubectl` command is issued with the `--user` option for the first time, your browser window will open and require you to authenticate.

    The read-only user has a `cluster-viewer` Kubernetes role bound to it's group, whereas the admin user, has the `admin` Kubernetes role bound to it's group.

    ```sh
    kubectl get pods -A --user oidc
    NAMESPACE          NAME                        READY   STATUS    RESTARTS   AGE
    amazon-guardduty   aws-guardduty-agent-bl2v2   1/1     Running   0          3h54m
    amazon-guardduty   aws-guardduty-agent-s1vcx   1/1     Running   0          3h54m
    amazon-guardduty   aws-guardduty-agent-w8gfc   1/1     Running   0          3h54m
    kube-system        aws-node-m9hmd              1/1     Running   0          3h53m
    kube-system        aws-node-w42b8              1/1     Running   0          3h53m
    kube-system        aws-node-wm6rm              1/1     Running   0          3h53m
    kube-system        coredns-6ff9c46cd8-94jlr    1/1     Running   0          3h59m
    kube-system        coredns-6ff9c46cd8-nw2rb    1/1     Running   0          3h59m
    kube-system        kube-proxy-7fb86            1/1     Running   0          3h54m
    kube-system        kube-proxy-p4f5g            1/1     Running   0          3h54m
    kube-system        kube-proxy-qk2mc            1/1     Running   0          3h54m
    ```

4. You can also use the `configure_kubectl` output to assume the *Cluster creator* role with `cluster-admin` access.

    ```sh
    configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name okta"
    ```

5. It's also possible to pre-configure your `kubeconfig` using the `okta_login` output. This will also require you to authenticate in a browser window.

    ```sh
    okta_login = "kubectl oidc-login setup --oidc-issuer-url=https://dev-ORGID.okta.com/oauth2/XXXXXXXXXXXXXXXXXX--oidc-client-id=XXXXXXXXXXXXXXXXXX"
    ```

## Cleanup

1. To tear down and delete all AWS provisioned resources related to this guidance, run the `terraform destroy` command from the same directory where `terraform apply..` command was run:

    ```sh
    cd guidance-for-amazon-eks-integrations-with-external-sso-providers-on-aws/source
    terraform destroy -auto-approve
    ```

## Next Steps

You are welcome to update the sample code provided in this guidance to adjust to your SSO provider settings and other configuration parameters. You can also contribute to the project by submitting a Pull Request which will be reviewed and processed by the maintainers.

## Notices

*Customers are responsible for making their own independent assessment of the information in this Guidance. This Guidance: (a) is for informational purposes only, (b) represents AWS current product offerings and practices, which are subject to change without notice, and (c) does not create any commitments or assurances from AWS and its affiliates, suppliers or licensors. AWS products or services are provided “as is” without warranties, representations, or conditions of any kind, whether express or implied. AWS responsibilities and liabilities to its customers are controlled by AWS agreements, and this Guidance is not part of, nor does it modify, any agreement between AWS and its customers.*

## Appendix

### Comparison table between SAML and OIDC Connect with Okta SSO

| Feature | SAML | OIDC Connect |
| - | - | - |
| K8s API Authentication Identity | AWS IAM Roles mapped to Okta users | Okta users directly |
| IAM Identity Provider | Needs to be created | Not needed |
| Multi EKS cluster support | Works only for EKS clusters within an AWS Account as IAM identities are Account scoped | Works across EKS clusters across AWS Accounts as Okta users are NOT tied IAM users |
| OIDC Service Quota of 100 | Need to create just only one IAM Identity Provider for Okta SAML that can be used across all EKS clusters in AWS Account | No need to create any IAM Identity Provider so Quota is not affected |
| User Management | Both places. Okta users/groups and corresponding IAM roles | Just need only Okta users/groups |
| Kubernetes RBAC | Needed to map to IAM roles | Needed to map to Okta user groups |
| Deployment | Substantially challenging | Straight forward |
| Multi cloud support | No as it is tied to AWS IAM | Yes as there is no IAM dependency |
| Recommended for Production | NO | YES |
| Authentication on EKS control plane | Uses IAM Authenticator on control plane | Uses OIDC Authenticator on control plane |
| Need for EKS Access Entries for Authentication | Yes needed | Not required |
| Basic Mechanism | It is for IAM/STS to exchange IAM temporary credentials for OIDC tokens. These temporary credentials (aka IAM roles) are then mapped to RBAC Mapping from IAM role to RBAC happens EKS Access entry mechanism which is a DIFFERENT authorization mechanism in EKS control plane than standard K8s RBAC | It is for K8s control plane to trust external OIDC providers for User identity. These Use identities are DIRECTLY mapped to RBAC Mapping from user Identity to RBAC happens via K8s standard RBAC mechanism i.e. `ClusterRole` and `ClusterRoleBindings` objects |

## Authors

- Rodrigo Bersa, Sr. WW Specialist SA, Containers
- Daniel Zilberman, Sr. Specialist SA, Technical Solutions
- Jayaprakash Alawala - Prin. GTM Specialist SA, Containers
