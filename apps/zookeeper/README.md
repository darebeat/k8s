# README

```sh
# 创建目录
mkdir -p /tmp/k8s/pv/{zk01,zk02,zk03}

# 创建pv
kubectl create -f zk-pv.yaml
kubectl get pv -o wide -n tools

# 部署zk集群
kubectl apply -f zk.yaml
# 查看pod情况
kubect get pods -n tools
# 验证Zk集群是否启动成功
for i in 0 1 2;
  do 
    echo "The Server is: zk-$i"; 
    kubectl exec zk-$i -n tools zkServer.sh status;
  done
```