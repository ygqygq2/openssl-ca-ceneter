#!/usr/bin/env bash
# 验证证书是否为CA签发

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <cert_file>"
    echo "Example: sh $0 certs/test.my.cn.crt"
    exit 1
fi

cert_file=$1

if [ -f ${cert_file} ];then
    echo -e "CA中心验证命令：\nopenssl verify -CAfile $CERT_DIR/${CA_NAME}.crt -verbose ${cert_file}\nCA中心验证结果："
    openssl verify -CAfile $CERT_DIR/${CA_NAME}.crt -verbose ${cert_file}
else
    echo -e "输入证书路径不对！！！"
    exit 1
fi
