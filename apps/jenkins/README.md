# README

#### 部署
```sh
kubectl create -f pvc.yaml
# kubectl create -f rbac.yaml
kubectl apply -f deployment.yaml

kubectl get pod -n tools -w
# 查看日志
kubectl logs `kubectl get pod -n tools | grep jenkins-server | awk '{print $1}'` -f -n tools

# 获取登陆初始密码
cat /tmp/k8s/pv/jenkins/secrets/initialAdminPassword
```

#### 配置jenkins动态slave

