# README

#### 用目录创建

```sh
kubectl create configmap game-config-dir --from-file=./dir
kubectl get configmap game-config-dir -o yaml
```

#### 使用文件创建


```sh
kubectl create configmap game-config-file --from-file=./dir/game.properties
kubectl get configmap game-config-file -o yaml
```


#### 使用字面值创建

```sh
kubectl create configmap special-config \
  --from-literal=special.how=very \
  --from-literal=special.type=charm

kubectlget configmaps special-config -o yaml
```
