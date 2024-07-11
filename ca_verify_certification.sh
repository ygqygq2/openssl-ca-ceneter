#!/usr/bin/env bash

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <domain_path>"
    echo "Example: sh $0 certs/server.crt"
    exit 1
fi

cert_file=$1

if [ -f ${cert_file} ];then
    echo -e "CA中心验证命令：\nopenssl verify -CAfile ${CAfile} -verbose ${cert_file}\nCA中心验证结果："
    ca_verify_log=$(openssl verify -CAfile  ${CERT_DIR}/${CA_NAME}.crt -verbose ${cert_file} 2>&1)
    echo $ca_verify_log
    if [ "$(echo ${ca_verify_log}|egrep 'error')" ];then
        exit 1
    fi
else
    echo -e "输入证书路径不对！！！"
    exit 1
fi

exit 0
