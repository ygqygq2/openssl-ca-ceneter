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
fi

exit 0
