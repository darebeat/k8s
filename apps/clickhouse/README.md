# README

```sh
kubectl exec -it clickhouse-0 -n tools bash

# 客户端连接方式
# 方式一 配置文件
cat > config.xml << EOF
<config>
    <host>127.0.0.1</host>
    <port>9000</port>
    <user>clickhouse</user>
    <password>clickhouse</password>
</config>
EOF

clickhouse-client -c config.xml --multiquery

# 手动指定登陆信息
clickhouse-client -u clickhouse --password clickhouse --multiquery
```

