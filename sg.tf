/* Security groups */
resource "exoscale_security_group" "sg" {
  name = "RulePorts"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}

resource "exoscale_security_group_rule" "http8080" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "SSH" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}

/* Security group for Prometheus Stuff*/

resource "exoscale_security_group_rule" "http9090" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9090 
  end_port = 9090
}

resource "exoscale_security_group_rule" "nodeExporter9100" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9100 
  end_port = 9100
}