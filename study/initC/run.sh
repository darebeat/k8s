#! /bin/bash -x

declare -r CURR_DIR=$(cd `dirname $0`; pwd)

if [[ $1 == "start" ]]; then
  # 启动
  kubectl apply -f ${CURR_DIR}/mypod.yaml
  # # 查看pod
  # kubectl get pod myapp-pod
  # # 查看pod描述信息
  # kubectl describe pod myapp-pod
  # # 查看和观察日志
  # kubectl logs myapp-pod -c init-service -f

  kubectl apply -f ${CURR_DIR}/myservice.yaml
  kubectl apply -f ${CURR_DIR}/mydb.yaml

  exit 0
elif [[ $1 == "stop" ]]; then
  # 停止
  kubectl delete -f ${CURR_DIR}/mydb.yaml
  kubectl delete -f ${CURR_DIR}/myservice.yaml
  kubectl delete -f ${CURR_DIR}/mypod.yaml

  exit 0
fi

exit 100