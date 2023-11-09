#!/usr/bin/env bash
set -ex

IMAGE_FQDN="${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}:${IMAGE_TAG}"

sudo service docker start
sudo docker login --username AWS --password-stdin "$IMAGE_REGISTRY" <<<"$ECR_TOKEN"
sudo docker pull "$IMAGE_FQDN"
sudo docker tag "$IMAGE_FQDN" "$IMAGE_LOCAL_NAME"
