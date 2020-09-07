
rm -rf ~/.kube

kubeadm init --config init.yml

wait

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# firewall-cmd --zone=public --add-port=6443/tcp --permanent && firewall-cmd --reload
# firewall-cmd --zone=public --add-port=10250/tcp --permanent && firewall-cmd --reload



kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl apply -f calico.yaml
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get pods --all-namespaces

