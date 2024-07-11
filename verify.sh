#!/usr/bin/env bash
# 验证证书是否为CA签发

<<<<<<< HEAD
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
=======
# 设置ca证书名
CA_NAME="my_CA"

# get pwd
cd `dirname $0`
real_path=`pwd`

cert_file=$1
CAfile=${real_path}/certs/${CA_NAME}.crt

if [ -f ${cert_file} ];then
        echo -e "CA中心验证命令：\nopenssl verify -CAfile ${CAfile} -verbose ${cert_file}\nCA中心验证结果："
	openssl verify -CAfile ${CAfile} -verbose ${cert_file}
else
        echo -e "输入证书路径不对！！！"
        exit 1
>>>>>>> 3116c479d8483f1c0ebbe4ca6dd641609ccf3ef0
fi
