<<<<<<< HEAD
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
=======
#!/bin/bash

# get pwd
cd `dirname $0`
real_path=`pwd`

server_flag=$1
agent=$(echo ${server_flag}|awk -F_ '{print $1}')
server_id=$(echo ${server_flag}|awk -F_ '{print $2}')
cert_file=${real_path}/certs/${agent}/${server_flag}.crt
CAfile=${real_path}/certs/my_CA.crt

if [ -f ${cert_file} ];then
	echo -e "CA中心验证命令：\nopenssl verify -CAfile ${CAfile} -verbose ${cert_file}\nCA中心验证结果："
	ca_verify_log=$(openssl verify -CAfile certs/my_CA.crt -verbose ${cert_file} 2>&1)
	echo $ca_verify_log
	if [ "$(echo ${ca_verify_log}|egrep 'error')" ];then
		exit 1
	fi
else
	echo -e "输入证书路径不对！！！"
	exit 1
>>>>>>> 3116c479d8483f1c0ebbe4ca6dd641609ccf3ef0
fi

exit 0
