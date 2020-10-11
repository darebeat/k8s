# README

```
# 注意: 如果单机测试,机器配置不高,建议只启动一个副本,不然,多余的副本一直在pending状态
mkdir -p /tmp/k8s/pv/{kafka01,kafka02,kafka03}
kubectl create -f kafka-pv.yaml
kubectl get pv -o wide -n tools

# 部署zk集群
kubectl apply -f kafka.yaml
# 查看pod情况
kubect get pods -n tools


# 验证Kafka集群是否启动成功
kubectl exec -it kafka-0 -n tools /bin/bash 

# 为方便书写,设置配置变量
ZKCFG="zk-0.zk-hs.tools.svc.cluster.local:2181,zk-1.zk-hs.tools.svc.cluster.local:2181,zk-2.zk-hs.tools.svc.cluster.local:2181"

# 创建Topic 
kafka-topics.sh --zookeeper ${ZKCFG} --create --partitions 1 --replication-factor 1 --topic mytest

# 查看Topic
kafka-topics.sh --zookeeper ${ZKCFG} --list

# 用Kafka的console-producer在topic mytest 生产消息
kafka-console-producer.sh --broker-list localhost:9092 --topic mytest

# 用Kafka的console-consumer 消费topic mytest 的消息
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic mytest --from-beginning
```