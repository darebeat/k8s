# README

initContainer 的用法实例,initC会顺序启动,myapp-pod会等待两个initC完成后再启动

```sh
# 启动
  kubectl apply -f mypod.yaml
  # # 查看pod
  # kubectl get pod myapp-pod
  # # 查看pod描述信息
  # kubectl describe pod myapp-pod
  # # 查看和观察日志
  # # 当initC启动成功后监控日志会自动退出
  # kubectl logs myapp-pod -c init-service -f

  kubectl apply -f myservice.yaml
  kubectl apply -f mydb.yaml
```