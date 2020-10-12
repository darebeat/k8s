# README

#### MYSQL数据库

- 修改secret.yaml文件，保存数据库密码

```sh
echo -n "mysql"| base64
kubectl apply -f secret.yaml 
```
- 创建mysql节点

```sh
mkdir -p /tmp/k8s/pv/azkaban/mysql/{data,logs}
kubectl apply -f mysql.yaml
```

~~*以后考虑使用initcontainers来初始化，减少手工操作(需要判断是否已经初始化)*~~

- 数据库数据初始化

```sh
kubectl exec -it `kubectl get pod -n tools | grep mysql | awk '{print $1}'` -n tools -- \
mysql -uroot -p azkaban < create-all-sql-3.84.4.sql
```

#### 创建executor节点

```sh
# 修改/创建节点配置文件
kubectl create -f exe-configmap.yaml 

# 创建exe节点
kubectl apply -f exe.yaml 

# - 已经实现exe节点在数据库中的自动激活，以下步骤可以跳过
#   通过使用pod生命周期钩子增加自动激活（文件active-exe.sh），和pod关闭前的自动失效

#   - *到数据库中查看exe节点注册情况*
#   - *在数据库中激活exe节点*

```sh
# 查看节点
kubectl exec -it `kubectl get pod -n tools | grep mysql | awk '{print $1}'` -n tools -- \
mysql -uazkaban -p -e "select * from azkaban.executors"

# 激活节点
kubectl exec -it `kubectl get pod -n tools | grep mysql | awk '{print $1}'` -n tools -- \
mysql -uazkaban -p -e "update azkaban.executors set active=1"
```

#### 创建web节点

```sh
# 修改/创建节点配置文件
kubectl create -f web-configmap.yaml 

# 创建web节点
kubectl apply -f web.yaml 

kubectl -n tools get svc

# 支持scale命令自动扩展exe节点
kubectl -n tools scale statefulset azkaban-exe --replicas=2
# select * from executors;
```

#### 登陆访问web ui

[http://localhost:31081](http://localhost:31081)

