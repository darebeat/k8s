# README

```sh
mkdir -p /tmp/k8s/pv/mysql/{data,logs}

kubectl apply -f mysql.yaml

kubectl get pod,svc,pv,pvc -n tools

mysql -h 127.0.0.1 -P 30001 -u root -p 
```