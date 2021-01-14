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

# source: Janos Pasztor, https://github.com/FH-Cloud-Computing/sprint-2/
variable "exoscale_zone_id" {
  type = string
  description = "ID of the exoscale zone"
  default = "4da1b188-dcd6-4ff5-b7fd-bde984055548"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}

data "exoscale_compute_template" "CCvmubuntu" {
  zone = var.zone
  name = var.template
}
