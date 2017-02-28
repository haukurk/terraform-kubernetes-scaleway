#!/usr/bin/env bash

. ./ips.txt
cat > scw-install.sh << FIN
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo "DOCKER_OPTS='-H unix:///var/run/docker.sock --storage-driver aufs --label provider=scaleway --mtu=1500 --insecure-registry=10.0.0.0/8'" > /etc/default/docker
systemctl restart docker

apt-get update -qq \
 && apt-get install -y -q --no-install-recommends kubelet kubeadm kubectl kubernetes-cni \
 && apt-get clean

for arg in "\$@"
do
  case \$arg in
    'master')
      SUID=\$(scw-metadata --cached ID)
      PUBLIC_IP=\$(scw-metadata --cached PUBLIC_IP_ADDRESS)
      PRIVATE_IP=\$(scw-metadata --cached PRIVATE_IP)


      kubeadm --token=\$KUBERNETES_TOKEN --api-advertise-addresses=\$PUBLIC_IP --api-external-dns-names=\$SUID.pub.cloud.scaleway.com init
      kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
      kubectl create -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/calico.yaml
      git clone https://github.com/kubernetes/heapster.git
      kubectl create -f heapster/deploy/kube-config/influxdb/
      kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
      break
      ;;
    'slave')
      kubeadm join --token \$KUBERNETES_TOKEN $MASTER_00
      break
      ;;
 esac
done
FIN
rm -rf ./ips.txt
