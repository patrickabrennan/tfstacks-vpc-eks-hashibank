locals {
  tags = {
    Blueprint  = var.cluster_name
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.1"

  cluster_name          = var.cluster_name
  cluster_endpoint      = var.cluster_endpoint
  cluster_version       = var.cluster_version
  oidc_provider_arn     = var.oidc_provider_arn
  enable_argo_workflows = false

  # We want to wait for the Fargate profiles to be deployed first
  #create_delay_dependencies = [for prof in module.eks.fargate_profiles : prof.fargate_profile_arn]

  # EKS Add-ons
  eks_addons = {
    coredns = {
      addon_version = "v1.11.4-eksbuild.14"
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that the we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        replicaCount = 1
        resources = {
          limits = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })

      timeouts = {
        create = "25m"
        delete = "10m"
      }

    }

    vpc-cni    = {
      #addon_version = "v1.18.3-eksbuild.1"
    }

    kube-proxy = {
      #addon_version = "v1.30.0-eksbuild.3"
    }
    
  }

  # Enable Fargate logging
  enable_fargate_fluentbit = false

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    most_recent = true
    set = [
      {
        name  = "vpcId"
        value = var.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
    ]
  }

  tags = local.tags
}
