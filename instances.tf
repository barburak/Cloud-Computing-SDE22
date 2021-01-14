/* Instancepool with HTTP Load Generator */
resource "exoscale_instance_pool" "CCinstancepool" {
  zone = var.zone
  name = "CCinstancepool"
  description = "Instance Pool - Managed by Terraform for Cloud Computing!"
  template_id = data.exoscale_compute_template.CCvmubuntu.id
  size = 2
  service_offering = "micro"
  disk_size = 10
  key_pair = exoscale_ssh_keypair.adminCC.name
  security_group_ids = [exoscale_security_group.sg.id]

  user_data =file("userdataPool.sh")
}

/* Instance for Monitoring with Prometheus, Visualized with Grafana */
resource "exoscale_compute" "Monitoring" {
  zone = var.zone
  display_name = "Monitoring"
  size = "micro"
  template_id = data.exoscale_compute_template.CCvmubuntu.id
  disk_size = 10
  key_pair = exoscale_ssh_keypair.adminCC.name
  security_group_ids = [exoscale_security_group.sg.id]

  user_data = templatefile("userdataMonitoring.sh.tpl", {
    exoscale_key=var.exoscale_key
    exoscale_secret=var.exoscale_secret
    exoscale_zone_id=var.exoscale_zone_id
    instance_pool_id=exoscale_instance_pool.CCinstancepool.id
    dashboard = file("CCDashboard.json")
  })
}