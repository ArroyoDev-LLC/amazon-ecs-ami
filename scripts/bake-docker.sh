#!/usr/bin/env bash
set -ex

IMAGE_FQDN="${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}:${IMAGE_TAG}"
IMAGE_FQDN_LATEST="${IMAGE_REPOSITORY}:latest"

sudo service docker start
sudo systemctl status docker
sudo systemctl enable --now docker.service
sudo docker login --username AWS --password-stdin "$IMAGE_REGISTRY" <<<"$ECR_TOKEN"
sudo docker pull "$IMAGE_FQDN"
sudo docker tag "$IMAGE_FQDN" "$IMAGE_LOCAL_NAME"
sudo docker tag "$IMAGE_FQDN" "$IMAGE_FQDN_LATEST"
