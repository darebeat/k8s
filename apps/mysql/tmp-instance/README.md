# README

```sh
# 运行实例
kubectl apply -f all.yaml

# 查看实例情况
kubectl get rc,svc

# 本地进入数据库
mysql -h 127.0.0.1 -P 30006 -uroot -p

# 停止实例
kubectl delete -f all.yaml
```