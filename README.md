# README

#### 验证集群状态

```sh
kubectl cluster-info
kubectl get nodes
kubectl describe node
```


#### 部署kubernetes dashboard

```sh
kubectl create -f kubernetes-dashboard.yaml
# kubectl apply -f kubernetes-dashboard.yaml

# 开启本机代理 
# 方式一 前台启动
kubectl proxy
# 方式二 后台启动
nohup kubectl proxy >/dev/null &
```

[启动后可登陆访问：](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login)



#### 需要获取Token，命令如下

```sh
kubectl -n kube-system describe secret default| awk '$1=="token:"{print $2}'
```