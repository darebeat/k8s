# README

#### 系统初始化

```sh
# 设置系统主机名以及 Host 文件的相互解析
cat >> /etc/hosts << EOF
k8s.docker.internal
EOF

# 关闭 防火墙&selinux&swap
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# 安装依赖包
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget

# 调整内核参数，对于 K8S
cat > /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

sysctl -p /etc/sysctl.d/kubernetes.conf
```


#### kube-proxy开启ipvs的前置条件

```sh
modprobe br_netfilter

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && \
bash /etc/sysconfig/modules/ipvs.modules && \
lsmod | grep -e ip_vs -e nf_conntrack
```

#### 安装 Docker 软件

```sh
wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum -y install docker-ce

systemctl enable docker
systemctl start docker

cat <<EOF >/etc/docker/daemon.json
{
  "registry-mirrors": ["https://w3qtirff.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl restart docker
```

#### 安装kubeadm,kubelet和kubectl（kubectl可以不必在所有节点上安装）

```sh
cat <<EOF >>/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
enabled=1
EOF

yum -y install kubelet kubeadm kubectl
systemctl enable kubelet
```

#### 初始化主节点

```sh
# 查看k8s部署需要的镜像版本
kubeadm config images list


cat << EOF >> k8s_img_pull.sh
#!/bin/bash
set -e

KUBE_VERSION=${1:-v1.19.2}
KUBE_DASHBOARD_VERSION=v1.10.1
KUBE_PAUSE_VERSION=3.2
ETCD_VERSION=3.4.13-0
COREDNS_VERSION=1.7.0

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
EOF

bash k8s_img_pull.sh

# 初始化启动 Master
kubeadm init --config=kubeadm-config.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yaml


# 停止K8S
kubeadm reset
rm -rf $HOME/.kube

# 检测集群状态
kubectl get cs

# 确保所有的Pod都处于Running状态
kubectl get pod --all-namespaces -o wide

# kube-proxy开启ipvs
# 修改ConfigMap的kube-system/kube-proxy中的config.conf，把 mode: "" 改为mode: “ipvs" 保存退出即可
kubectl edit cm kube-proxy -n kube-system


# 删除之前的proxy pod
kubectl get pod -n kube-system |grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'

# 查看proxy运行状态
kubectl get pod -n kube-system |grep kube-proxy 

#查看日志,如果有 `Using ipvs Proxier.` 说明kube-proxy的ipvs 开启成功!
kubectl logs `kubectl get pod -n kube-system |grep kube-proxy|awk '{print $1}'` -n kube-system | grep ipvs
```