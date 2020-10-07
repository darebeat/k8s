
# ubuntu 16.04替换源
cat << EOF > /etc/apt/sources.list
deb-src http://archive.ubuntu.com/ubuntu xenial main restricted
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/xenial-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu xenial partner
deb-src http://archive.canonical.com/ubuntu xenial partner
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse
EOF

apt-get update

# 关闭防火墙
ufw disable

apt install selinux-utils

setenforce 0
cat << EOF >> /etc/selinux/conifg
SELINUX=disabled
EOF


# 设置网络:

cat << EOF >> /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

modprobe br_netfilter

# 查看 ipv4 与 v6 配置是否生效:
sysctl --system

# 配置 iptables:

iptables -P FORWARD ACCEPT

cat << EOF >> /etc/rc.local
/usr/sbin/iptables -P FORWARD ACCEPT
EOF

# 永久关闭 swap 分区:
sed -i 's/.*swap.*/#&/' /etc/fstab

# 安装docker
apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 

apt-get update
apt-get purge docker-ce docker docker-engine docker.io  && rm -rf /var/lib/docker
apt-get autoremove docker-ce docker docker-engine docker.io
apt-get install -y docker-ce


# 安装 k8s
apt-get update && apt-get install -y apt-transport-https curl firewalld
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

apt-get update
apt-get purge kubelet kubeadm kubectl
apt-get autoremove kubelet kubeadm kubectl
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# 启动服务并设置开机自动重启:
systemctl enable kubelet && sudo systemctl start kubelet

# 查看kubeadm镜像
# kubeadm config images list
for i in `kubeadm config images list`; do 
  imageName=${i#k8s.gcr.io/}
  docker pull registry.aliyuncs.com/google_containers/$imageName
  docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.aliyuncs.com/google_containers/$imageName
done;

# 开机启动 && 启动服务
systemctl enable kubelet && systemctl start kubelet


# k8s集群初始化
firewall-cmd --zone=public --add-port=6443/tcp --permanent && firewall-cmd --reload
firewall-cmd --zone=public --add-port=10250/tcp --permanent && firewall-cmd --reload

