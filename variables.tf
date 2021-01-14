/* variables for VMs */
variable "exoscale_key" {
  description = "Please enter Exoscale API key:"
  type = string
}
variable "exoscale_secret" {
  description = "Please enter Exoscale API secret:"
  type = string
}

variable "zone" {
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}

data "exoscale_compute_template" "CCvmubuntu" {
  zone = var.zone
  name = var.template
}
