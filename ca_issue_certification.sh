<<<<<<< HEAD
#!/usr/env/bin bash
# 根据已有 csr 签发证书
# 将 csr 文件以 <domain_name>.csr 命名放在 csr 目录下

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <domain>"
    echo "Example: sh $0 domain1"
    exit 1
fi

domain_name="$1"

openssl ca -config ${real_path}/openssl.cnf -utf8 -extfile v3.ext \
  -in ${CSR_DIR}/${domain_name}.csr -cert ${CERT_DIR}/${CA_NAME}.crt -keyfile ${KEY_DIR}/${CA_NAME}.key -out ${CERT_DIR}/${domain_name}.crt

rsync -avz ${CERT_DIR}/${domain_name}.csr ${CERT_DIR}/${domain_name}-${TODAY}.csr
rsync -avz ${CERT_DIR}/${domain_name}.crt ${CERT_DIR}/${domain_name}-${TODAY}.crt


=======
#!/bin/bash

server_flag=$1
agent=$(echo ${server_flag}|awk -F_ '{print $1}')
server_id=$(echo ${server_flag}|awk -F_ '{print $2}')

# get pwd
cd `dirname $0`
real_path=`pwd`
TODAY=$(date +%F)
KEY_DIR=${real_path}/private/${agent}
CERT_DIR=${real_path}/certs/${agent}
CSR_DIR=${real_path}/csrs/${agent}
newCERT_DIR=${real_path}/newcerts/	#自动生成证书路径，openssl.cnf中配置的（相当于备份）
CONF_DIR=${real_path}/conf
ca_log=${real_path}/ca_issue_certification.log

[ ! -d ${KEY_DIR} ] && mkdir -p ${KEY_DIR}/
[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}/
[ ! -d ${CSR_DIR} ] && mkdir -p ${CSR_DIR}/
[ ! -d ${newCERT_DIR} ] && mkdir -p ${newCERT_DIR}/
[ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR}/

[ ! -f ${CSR_DIR}/${server_flag}.csr ] && { echo -e "\e[1;31m缺少请求文件！\e[0m" ; exit 1 ; }

check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
until [[ -z "${check_autoanswer_pid}" ]];do
        echo -e "CA签证排队中......" && sleep 5
        check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
done

/usr/bin/expect ${real_path}/autoanswer.exp ${agent} ${server_id}
if [ $? -eq 0 ] ;then
	echo -e "\e[1;32mCA签证成功。\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${server_flag} successed\n" >> ${ca_log}
	rsync -avz ${CSR_DIR}/${server_flag}.csr ${CSR_DIR}/${server_flag}_${TODAY}.csr
	rsync -avz ${CERT_DIR}/${server_flag}.crt ${CERT_DIR}/${server_flag}_${TODAY}.crt
else
	echo -e "\e[1;31mCA签证失败！\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${server_flag} failed\n" >> ${ca_log}
	exit 1
fi

exit 0
>>>>>>> 3116c479d8483f1c0ebbe4ca6dd641609ccf3ef0
