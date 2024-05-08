#!/usr/bin/env bash
set -ex

LUSTRE_VERSION=${LUSTRE_VERSION:-2.15}

sudo amazon-linux-extras install -y "lustre${LUSTRE_VERSION}"
