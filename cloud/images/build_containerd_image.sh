#!/bin/bash

if [ $# -lt 1 ]; then
    echo "usage: $0 {image_name}"
    exit 1
fi

# 参数定义
image_name=$1 # 镜像名称，包含tag，例如redis-shake:1.0

# 常量定义
dockerimage_prefix="docker.io/library/" # docker镜像在crictl中显示的前缀

# 根据dockerfile制作docker镜像
docker build -t ${image_name} .

# save镜像
docker save -o ${image_name//:/-}".tar" ${image_name}

# 导入save的docker镜像，导入之前先删除上次导入的同名镜像
# ctr分很多namespace，导入镜像时需用k8s.io的名空间，这样crictl命令才可以看到
ctr -n k8s.io images delete ${dockerimage_prefix}${image_name}
ctr -n k8s.io images import ${image_name//:/-}".tar"

# 删除docker镜像和tar包
docker image rm ${image_name}
rm -f ${image_name//:/-}".tar" 

# 查看镜像
crictl --runtime-endpoint unix:////run/containerd/containerd.sock images | grep ${image_name%:*}

