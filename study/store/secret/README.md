# Secret

Secret 解决了密码、token、密钥等敏感数据的配置问题，而不需要把这些敏感数据暴露到镜像或者 Pod Spec中。
Secret 可以以 Volume 或者环境变量的方式使用

#### Secret 有三种类型：

+ Service Account：用来访问 Kubernetes API，由 Kubernetes 自动创建，并且会自动挂载到 Pod 的/run/secrets/kubernetes.io/serviceaccount目录中
+ Opaque：base64编码格式的Secret，用来存储密码、密钥等
+ kubernetes.io/dockerconfigjson：用来存储私有 docker registry 的认证信息

#### Service Account

```sh
kubectl run nginx --image nginx
kubectl get pods
kubectl exec -it `kubectl get pod | grep ^nginx | awk 'NR==1{print $1}'` -- ls -lF /run/secrets/kubernetes.io/serviceaccount
```

#### Opaque Secret

`opaque-secret.yaml`