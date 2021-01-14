/* Network Load Balancer */
resource "exoscale_nlb" "CCnlb" {
  name = "CCnlb"
  description = "NLB - Managed by Terraform for Cloud Computing!"
  zone = var.zone
}

resource "exoscale_nlb_service" "CCnlbservice" {
  zone = exoscale_nlb.CCnlb.zone
  name = "CCnlbservice"
  description = "NLB - Managed by Terraform for Cloud Computing!"
  nlb_id = exoscale_nlb.CCnlb.id
  instance_pool_id = exoscale_instance_pool.CCinstancepool.id
  protocol = "tcp"
  port = 80
  target_port = 8080
  strategy = "round-robin"

  healthcheck {
    mode = "http"
    uri = "/health"
    port = 8080
    interval = 5
    timeout = 3
    retries = 1
  }

  depends_on = [
    exoscale_instance_pool.CCinstancepool
  ]

}