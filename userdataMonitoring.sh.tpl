#!/bin/bash

# source code from sprint 2: Janos Pasztor, https://github.com/FH-Cloud-Computing/sprint-2/
# Abort on all errors
set -e

# This is not production grade, but for the sake of brevity we are using it like this.
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Create shared directory for service discovery config
mkdir -p /srv/service-discovery/
chmod a+rwx /srv/service-discovery/

# Write Prometheus config
cat <<EOCF >/srv/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'service discovery'
    file_sd_configs:
      - files:
          - /srv/service-discovery/config.json
        refresh_interval: 10s
EOCF

# Creates a docker network
docker network create monitoring

# Run service discovery agent
docker run \
    -d \
    --name sd \
    --network monitoring \
    -v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools \
    quay.io/janoszen/prometheus-sd-exoscale-instance-pools:1.0.0 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}

# Run Prometheus
docker run -d \
    -p 9090:9090 \
    --name prometheus \
    --network monitoring \
    -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /srv/service-discovery/:/srv/service-discovery/ \
    quay.io/prometheus/prometheus

# Create shared directory for Grafana config
sudo mkdir -p /srv/grafana/provisioning/datasources/
sudo chmod a+rwx /srv/grafana/provisioning/datasources/

# Write Grafana config
# Some code snippets from: https://grafana.com/docs/grafana/latest/administration/provisioning/
# and from Janos Pasztor: https://fh-cloud-computing.github.io/exercises/5-grafana/
cat <<EOCF >/srv/grafana/provisioning/datasources/grafana.yaml
apiVersion: 1

datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  orgId: 1
  url: http://prometheus:9090
  version: 1
  editable: false
EOCF

# Create shared directory for Grafana notification channels
sudo mkdir -p /srv/grafana/provisioning/notifiers/
sudo chmod a+rwx /srv/grafana/provisioning/notifiers/

cat <<EOCF >/srv/grafana/provisioning/notifiers/notifiers.yaml
notifiers:
  - name: Scale up
    type: webhook
    uid: buVeHZfMk
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://autoscaler:8090/up"
  - name: Scale down
    type: webhook
    uid: ECpRDZfMk
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://autoscaler:8090/down"
EOCF

# Create shared directory for Grafana dashboard
sudo mkdir -p /srv/grafana/provisioning/dashboards/
sudo chmod a+rwx /srv/grafana/provisioning/dashboards/

cat <<EOCF >/srv/grafana/provisioning/dashboards/dashboard.yaml
apiVersion: 1

providers:
- name: 'Home'
  orgId: 1
  folder: ''
  type: file
  updateIntervalSeconds: 10
  options:
    path: /etc/grafana/dashboards
EOCF

# Create shared directory for Grafana dashboard
sudo mkdir -p /srv/grafana/dashboards/
sudo chmod a+rwx /srv/grafana/dashboards/

cat <<EOCF >/srv/grafana/dashboards/dashboard.json
${dashboard}
EOCF


# Run Grafana
sudo docker run -d \
    -p 3000:3000 \
    --name grafana \
    --network monitoring \
    -v /srv/grafana/provisioning/datasources/grafana.yaml:/etc/grafana/provisioning/datasources/grafana.yaml \
    -v /srv/grafana/provisioning/notifiers/notifiers.yaml:/etc/grafana/provisioning/notifiers/notifiers.yaml \
    -v /srv/grafana/provisioning/dashboards/dashboard.yaml:/etc/grafana/provisioning/dashboards/dashboard.yaml \
    -v /srv/grafana/dashboards/dashboard.json:/etc/grafana/dashboards/dashboard.json \
    grafana/grafana

# Run Autoscaler
# Source: Janos Pasztor https://github.com/janoszen/exoscale-grafana-autoscaler
sudo docker run -d \
    -p 8090:8090 \
    --name autoscaler\
    --netowork monitoring \
    quay.io/janoszen/exoscale-grafana-autoscaler:1.0.2 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}