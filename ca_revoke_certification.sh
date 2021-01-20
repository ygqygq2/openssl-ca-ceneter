#!/bin/bash

# get pwd
cd `dirname $0`
real_path=`pwd`

server_flag=$1
agent=$(echo ${server_flag}|awk -F_ '{print $1}')
server_id=$(echo ${server_flag}|awk -F_ '{print $2}')
cert_file=${real_path}/certs/${agent}/${server_flag}.crt
CAfile=${real_path}/certs/my_CA.crt
ca_log=${real_path}/ca_revoke_certification.log

[ -f ${cert_file} ] && openssl ca -revoke ${cert_file}
if [ $? -eq 0 ] ;then
        echo -e "\e[1;32mCA数据库更新成功。\e[0m" && echo -e "$(date +%F-%T)\tca revoke certification to ${server_flag} successed\n" >> ${ca_log}
else
        echo -e "\e[1;31mCA数据库更新失败！\e[0m" && echo -e "$(date +%F-%T)\tca revoke certification to ${server_flag} failed\n" >> ${ca_log}
        exit 1
fi

# 准备公开被吊销的证书列表时，可以生成证书吊销列表（CRL）,此步不做处理了。
#openssl ca -gencrl -out ${real_path}/crl.pem

exit 0
