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

echo "Installing k[03]s install scripts"
for j in 0 3; do
    curl -sfL https://get.k${j}s.io > /usr/bin/install-k${j}s
    chmod 755 /usr/bin/install-k${j}s
done

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

