#!/bin/bash
set -e

KUBE_VERSION=${1:-v1.16.5}
KUBE_DASHBOARD_VERSION=v1.10.1
KUBE_PAUSE_VERSION=3.1
ETCD_VERSION=3.3.15-0
COREDNS_VERSION=1.6.2

# 这里为了使国内拉取镜像更快，使用了mirrorgooglecontainers进行拉取
GCR_URL=k8s.gcr.io  # 此处修改为了k8s.gcr.io

#GCR_URL=k8s.gcr.io
ALIYUN_URL=registry.cn-hangzhou.aliyuncs.com/google_containers

#get images
images=(kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
kube-apiserver:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
coredns:${COREDNS_VERSION}
kubernetes-dashboard-amd64:${KUBE_DASHBOARD_VERSION})

for imageName in ${images[@]} ; do
  docker pull $ALIYUN_URL/$imageName
  docker tag $ALIYUN_URL/$imageName $GCR_URL/$imageName
  docker rmi $ALIYUN_URL/$imageName
done
docker images
