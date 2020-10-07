# README

```sh
wget https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/deploy/static/mandatory.yaml

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:0.30.0

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:0.30.0 \
quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0

# 部署
kubectl apply -f mandatory.yaml
# 查看deploy
kubectl -n ingress-nginx get pods 
# 查看pod详情
kubectl -n ingress-nginx describe pod `kubectl -n ingress-nginx get pods | awk '{print $1}'`
# 查看svc
kubectl -n ingress-nginx get svc
```