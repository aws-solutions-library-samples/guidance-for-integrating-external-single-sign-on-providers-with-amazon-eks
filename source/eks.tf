################################################################################
# Cluster
################################################################################

module "eks" {
  #checkov:skip=CKV_TF_1:Hardcode a hash is not a best practice for minor and bug fixes versions.
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                   = "${var.name}-eks"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      before_compute = true # Ensure the addon is configured before compute resources are created
      most_recent    = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_identity_providers = {
    okta = {
      name           = "Okta"
      issuer_url     = okta_auth_server.eks.issuer
      client_id      = okta_app_oauth.eks.client_id
      username_claim = "email"
      groups_claim   = "groups"
    }
  }

  eks_managed_node_groups = {
    core_nodegroup = {
      description = "EKS Core Managed Node Group for hosting system add-ons"
      #Use AWS Graviton based AMI for compute nodes
      instance_types = ["m7g.large"]
      ami_type       = "BOTTLEROCKET_ARM_64"

      min_size     = 2
      max_size     = 5
      desired_size = 3

      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
      iam_role_policy_statements = [
        {
          sid    = "ECRPullThroughCache"
          effect = "Allow"
          actions = [
            "ecr:CreateRepository",
            "ecr:BatchImportUpstreamImage",
          ]
          resources = ["*"]
        }
      ]

      ebs_optimized     = true
      enable_monitoring = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
        xvdb = {
          device_name = "/dev/xvdb"
          ebs = {
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true

          }
        }
      }

      tags = local.tags
    }
  }
}
