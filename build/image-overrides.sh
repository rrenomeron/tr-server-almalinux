#!/usr/bin/bash

set -eoux pipefail

# Use this for build steps that are unique to this particular image

echo "Installing additional server packages"
dnf install -y \
    git \
    firewalld \
    cloud-init \
    setroubleshoot-server

echo "Installing k0s"

curl -sSLf https://get.k0s.sh | sh
mv /usr/local/bin/k0s /usr/bin

