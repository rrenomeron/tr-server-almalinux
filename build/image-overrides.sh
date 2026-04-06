#!/usr/bin/bash

set -eoux pipefail

# Use this for build steps that are unique to this particular image

echo "Installing additional server packages"
dnf install -y --setopt=install_weak_deps=false \
    epel-release \
    git \
    firewalld \
    cloud-init \
    setroubleshoot-server

echo "Installing k0s"

curl -sSLf https://github.com/k0sproject/k0s/releases/download/v1.35.2%2Bk0s.0/k0s-v1.35.2+k0s.0-amd64 > /tmp/k0s
mv /tmp/k0s /usr/bin
chmod 755 /usr/bin/k0s

echo "Installing Kubernetes tools"
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubectl helm

rm /etc/yum.repos.d/kubernetes.repo

