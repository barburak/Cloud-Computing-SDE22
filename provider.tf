terraform {
  required_providers {
    exoscale = {
      source  = "terraform-providers/exoscale"
    }
  }
}

variable "exoscale_key" {
  description = "Please enter Exoscale API key:"
  type = string
}
variable "exoscale_secret" {
  description = "Please enter Exoscale API secret:"
  type = string
}
provider "exoscale" {
  key = var.exoscale_key
  secret = var.exoscale_secret
}


