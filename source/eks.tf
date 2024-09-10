################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                   = "${var.name}-eks"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    eks-operators = {
      kubernetes_groups = ["eks-operators"]
      principal_arn     = aws_iam_role.eks_operators.arn

      policy_associations = {
        clsuter_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    eks-developers = {
      kubernetes_groups = ["eks-developers"]
      principal_arn     = aws_iam_role.eks_developers.arn

      policy_associations = {
        cluster_view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        namespace_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["default"]
          }
        }
      }
    }
  }

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
      description    = "EKS Core Managed Node Group for hosting system add-ons"
      instance_types = ["m5a.large", "m5.xlarge", "t3.large", "t3a.large"]
      ami_type       = "BOTTLEROCKET_x86_64"

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

      node_security_group_tags = {
        "karpenter.sh/discovery" = "${var.name}-eks"
      }

      tags = local.tags
    }
  }
}
