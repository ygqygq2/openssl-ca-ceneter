#!/usr/bin/env bash
# 吊销证书

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
ca_log=${real_path}/ca_revoke_certification.log

if [ -f "${cert_file}" ]; then
    # 如果存在，则尝试撤销证书
    openssl ca -revoke "${cert_file}"
    # 获取上一个命令的退出状态
    result=$?
    if [ ${result} -eq 0 ]; then
        # 如果撤销成功，更新日志并显示成功消息
        echo -e "\e[1;32mCA数据库更新成功。\e[0m"
        echo -e "$(date +%F-%T)\tca revoke certification to ${cert_file} succeeded\n" >> "${ca_log}"
    else
        # 如果撤销失败，更新日志并显示失败消息，然后退出脚本
        echo -e "\e[1;31mCA数据库更新失败！\e[0m"
        echo -e "$(date +%F-%T)\tca revoke certification to ${cert_file} failed\n" >> "${ca_log}"
        exit 1
    fi
else
    # 如果证书文件不存在，显示错误消息
    echo -e "\e[1;31m证书文件不存在！\e[0m"
    exit 1
fi

# 准备公开被吊销的证书列表时，可以生成证书吊销列表（CRL）,此步不做处理了。
#openssl ca -gencrl -out ${real_path}/crl.pem

exit 0
