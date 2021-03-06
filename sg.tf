/* Security groups */
resource "exoscale_security_group" "sg" {
  name = "RulePorts"
}

resource "exoscale_security_group_rule" "http8080healthcheck" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "http22SSH" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}

/* Security group for Prometheus & Grafana Stuff*/

resource "exoscale_security_group_rule" "http9090prometheus" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9090 
  end_port = 9090
}

resource "exoscale_security_group_rule" "http9100nodeExporter" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9100 
  end_port = 9100
}

resource "exoscale_security_group_rule" "http3000grafana" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 3000
  end_port = 3000
}

resource "exoscale_security_group_rule" "http8090autoscaler" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8090
  end_port = 8090
}