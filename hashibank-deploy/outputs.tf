output "public_dns_name" {
  description = "Public DNS name of load balancer"
  value = kubernetes_ingress_v1.hashibank
}
