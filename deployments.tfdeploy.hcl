identity_token "aws" {
  audience = ["aws.workload.identity"]
}


identity_token "k8s" {
  audience = ["aws.workload.identity"]
}


deployment "development" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::285942769742:role/hcp-oidc"
    regions             = ["us-east-2"]
    vpc_name = "vpc-brennan-dev1"
    vpc_cidr = "10.0.0.0/16"

    #EKS Cluster
    kubernetes_version = "1.33"
    cluster_name = "eks-brennan-dev01"
    
    #EKS OIDC
    tfc_kubernetes_audience = "aws.workload.identity"
    tfc_hostname = "https://app.terraform.io"
    tfc_organization_name = "patrick-brennan-demo-org"
    eks_clusteradmin_arn = "arn:aws:iam::285942769742:role/aws_patrick.brennan_test-developer"
    eks_clusteradmin_username = "aws_patrick.brennan_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s.jwt
    namespace = "hashibank"

  }
  # flip this on only when you intend to destroy
  #destroy = true
}

deployment "prod" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::285942769742:role/hcp-oidc"
    regions             = ["us-east-1"]
    vpc_name = "vpc-brennan-prod1"
    vpc_cidr = "10.20.0.0/16"

    #EKS Cluster
    kubernetes_version = "1.33"
    cluster_name = "eks-brennan-prod01"
    
    #EKS OIDC
    tfc_kubernetes_audience = "aws.workload.identity"
    tfc_hostname = "https://app.terraform.io"
    tfc_organization_name = "patrick-brennan-demo-org"
    eks_clusteradmin_arn = "arn:aws:iam::285942769742:role/aws_patrick.brennan_test-developer"
    eks_clusteradmin_username = "aws_patrick.brennan_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s.jwt
    namespace = "hashibank"

  }
  # flip this on only when you intend to destroy
  #destroy = true
}

#comment out as this for Beta version 
#orchestrate "auto_approve" "safe_plans_dev" {
#  check {
#      # Only auto-approve in the development environment if no resources are being removed
#      condition = context.plan.changes.remove == 0 && context.plan.deployment == deployment.development
#      reason = "Plan has ${context.plan.changes.remove} resources to be removed."
#  }
#}

#add for GA version
# GA: gate/approval lives on a deployment_group + auto-approve check
#deployment_group "dev" {
#  auto_approve_checks = [deployment_auto_approve.no_destroy_dev]
#}

#deployment_auto_approve "no_destroy_dev" {
#  check {
#    condition = context.plan.changes.remove == 0 && context.plan.deployment == deployment.development
#    reason    = "Prevent auto-approval if anything would be destroyed."
#  }
#}

