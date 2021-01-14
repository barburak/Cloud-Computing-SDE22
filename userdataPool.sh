#!/bin/bash

set -e
apt update

# region Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Run the http load generator
docker run -d \
  --restart=always \
  -p 8080:8080 \
  quay.io/janoszen/http-load-generator:1.0.1

# Run node exporter
sudo docker run -d -p 9100:9100 --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter --path.rootfs=/host