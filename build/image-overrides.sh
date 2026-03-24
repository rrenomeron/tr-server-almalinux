#!/usr/bin/bash

set -eoux pipefail

# Use this for build steps that are unique to this particular image

echo "Installing additional server packages"
dnf install -y \
    git \
    firewalld \
    cloud-init
    
