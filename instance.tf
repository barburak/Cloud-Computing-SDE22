/* VM Instance Variables */
variable "zone" {
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}

data "exoscale_compute_template" "CCvmachine" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "CCinstancepool" {
  zone = var.zone
  name = "CCinstancepool"
  description = "Instance Pool - Managed by Terraform for Cloud Computing!"
  template_id = data.exoscale_compute_template.CCvmachine.id
  size = 2
  service_offering = "micro"
  disk_size = 10
  key_pair = exoscale_ssh_keypair.adminCC.name
  security_group_ids = [exoscale_security_group.sg.id]
  user_data =<<EOF
#!/bin/bash

set -e
apt update

# region Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo sh get-docker.sh

# Run the http load generator
docker run -d \
  --restart=always \
  -p 8080:8080 \
  janoszen/http-load-generator:1.0.1
  
# Run node explorer
sudo docker run -d -p 9100:9100 --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter --path.rootfs=/host
EOF

}

resource "exoscale_compute" "prometheusMonitor" {
  zone = var.zone
  display_name = "prometheusMonitor"
  size = "micro"
  template_id = data.exoscale_compute_template.CCvmachine.id
  disk_size = 10
  key_pair = exoscale_ssh_keypair.adminCC.name
  security_group_ids = [exoscale_security_group.sg.id]
  user_data =<<EOF
#!/bin/bash

set -e

# region Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

mkdir -p /srv/service-discovery/
chmod a+rwx /srv/service-discovery/

sudo echo "[
  {
    "targets": ["localhost:9100"]
  }
]" > /srv/service-discovery/custom_servers.json;

sudo echo "global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'service discovery'
    file_sd_configs:
      - files:
        - /srv/service-discovery/config.json
        refresh_interval: 10s" > /srv/prometheus.yml;

sudo mkdir /var/run/prometheus-sd-exoscale-instance-pools
chmod a+rwx /var/run/prometheus-sd-exoscale-instance-pools

sudo docker run -d \
    -v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools \
    janoszen/prometheus-sd-exoscale-instance-pools \
    --exoscale-api-key ${var.exoscale_key} \
    --exoscale-api-secret ${var.exoscale_secret} \
    --exoscale-zone-id 4da1b188-dcd6-4ff5-b7fd-bde984055548 \
    --instance-pool-id ${exoscale_instance_pool.CCinstancepool.id} \

# Run prometheus
sudo docker run -d -p 9090:9090 -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /srv/service-discovery/:/srv/service-discovery/ prom/prometheus
EOF
}
