#!/bin/bash

NODE_HOSTNAME=""
DISTRO="ubuntu"
CONTROL_PLANE_HOST=""
JOIN_TOKEN=""
DISCOVERY_TOKEN_CA_CERT_HASH=""

echo 'Setting hostname...'
hostnamectl set-hostname $NODE_HOSTNAME


echo 'Disabling swap...'
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo 'Configure containerd behavior...'
cat /etc/modules-load.d/containerd.conf

modprobe overlay
modprobe br_netfilter

echo 'Configure kubernetes.conf'
cat /etc/sysctl.d/kubernetes.conf

echo 'Reload changes...'
sysctl --system

echo 'Install required packages...'
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

echo 'Install docker repos...'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

cat /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_ubuntu-bookworm.list
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmour -o /etc/apt/keyrings/docker.gpg

echo 'Install and configure containerd...'
apt update
apt install -y containerd.io
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-bookworm.gpg
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

apt update
apt install -y kubelet kubeadm kubectl


# join cluster
kubeadm join $CONTROL_PLANE_HOST:6443 --token $JOIN_TOKEN --discovery-token-ca-cert-hash $DISCOVERY_TOKEN_CA_CERT_HASH
