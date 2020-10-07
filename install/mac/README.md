# README

1. 官网下载docker-ce,并安装
2. 查看docker自带的k8s版本
3. 找到k8s版本对应组件各自的版本(国内无法直接下载国外镜像,需换源下载到本地,并重命名)
4. 修改`docker-images-k8s.sh`中版本信息,完成后运行`./docker-images-k8s.sh`
5. 重启docker