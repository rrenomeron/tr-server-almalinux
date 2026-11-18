#!/usr/bin/bash

set -eoux pipefail

# Use this for build steps that are unique to this particular image

echo "Installing additional server packages"
dnf install -y --setopt=install_weak_deps=false \
    container-selinux \
    epel-release \
    git-core \
    firewalld \
    cloud-init \
    setroubleshoot-server

echo "Installing k[03]s install scripts"
for j in 0 3; do
    curl -sfL https://get.k${j}s.io > /usr/bin/install-k${j}s
    chmod 755 /usr/bin/install-k${j}s
done

cat <<EOF | tee /etc/yum.repos.d/rancher-k3s-common.repo
[rancher-k3s-common-stable]
name=Rancher K3s Common (stable)
baseurl=https://rpm.rancher.io/k3s/stable/common/centos/9/noarch
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://rpm.rancher.io/public.key
EOF

dnf -y install k3s-selinux

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
