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

curl -sSLf https://github.com/k0sproject/k0s/releases/download/v1.35.2%2Bk0s.0/k0s-v1.35.2+k0s.0-amd64 > /tmp/k0s
mv /tmp/k0s /usr/bin
chmod 755 /usr/bin/k0s

