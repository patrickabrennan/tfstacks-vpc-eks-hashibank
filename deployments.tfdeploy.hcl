identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}


identity_token "hcp" {
  audience = ["hcp.workload.identity"]
}

identity_token "k8s" {
  audience = ["k8s.workload.identity"]
}


deployment "development" {
  variables = {
    aws_identity_token_file = identity_token.aws.jwt_filename
    regions             = ["ap-southeast-1"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    vpc_name = "eks-vpc-dev2"
    vpc_cidr = "10.0.0.0/16"
    kubernetes_version = "1.28"
    cluster_name = "eks-cluster"
    manage_aws_auth_configmap = false
    
    #EKS OIDC
    tfc_kubernetes_audience = "k8s.workload.identity"
    tfc_hostname = "https://app.terraform.io"
    tfc_organization_name = "hashi-demos-apj"

    #K8S
    k8s_identity_token_file = identity_token.k8s.jwt_filename
    namespace = "hashibank"

  }
}