#!/bin/bash

set -euo pipefail

# Tell apt-get we're never going to be able to give manual feedback:
export DEBIAN_FRONTEND=noninteractive

# Update the package listing, so we know what packages exist:
apt-get update

# Install security updates:
apt-get -y upgrade

# Install our dependencies without unnecessary recommended packages:
apt-get -y install --no-install-recommends \
   openssh-client git curl rsync openssl ca-certificates \
   iproute2 iputils-ping

update-ca-certificates

# Delete cached files we don't need anymore:
apt-get clean
rm -rf /var/lib/apt/lists/*

