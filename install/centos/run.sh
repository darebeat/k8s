#! /bin/bash -x

declare -r CURR_DIR=$(cd `dirname $0`; pwd)

if [[ $1 == "start" ]]; then
  rm -rf ~/.kube

	kubeadm init --config ${CURR_DIR}/kubeadm-config.yaml

	mkdir -p $HOME/.kube
	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config

	kubectl taint nodes --all node-role.kubernetes.io/master-

	kubectl apply -f ${CURR_DIR}/kube-flannel.yaml
	kubectl get pods --all-namespaces

  exit 0
elif [[ $1 == "stop" ]]; then
  # 停止
  kubectl delete -f ${CURR_DIR}/kube-flannel.yaml
  sudo kubeadm reset
  sudo ipvsadm --clear


  rm -rf $HOME/.kube

  exit 0
fi

exit 100


