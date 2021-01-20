#!/usr/bin/env bash
# 验证证书是否为CA签发

# 设置ca证书名
ca_name="my_CA"

# get pwd
cd `dirname $0`
real_path=`pwd`

cert_file=$1
CAfile=${real_path}/certs/${ca_name}.crt

if [ -f ${cert_file} ];then
        echo -e "CA中心验证命令：\nopenssl verify -CAfile ${CAfile} -verbose ${cert_file}\nCA中心验证结果："
	openssl verify -CAfile ${CAfile} -verbose ${cert_file}
else
        echo -e "输入证书路径不对！！！"
        exit 1
fi
