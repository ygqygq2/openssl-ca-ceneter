#!/usr/bin/env bash

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
ca_log=${real_path}/ca_issue_certification.log

check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
until [[ -z "${check_autoanswer_pid}" ]];do
    echo -e "CA签证排队中......" && sleep 5
    check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
done

/usr/bin/expect ${real_path}/autoanswer.exp ${domain_name}
if [ $? -eq 0 ] ;then
    echo -e "\e[1;32mCA签证成功。\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${domain_name} successed\n" >> ${ca_log}
    rsync -avz ${CSR_DIR}/${domain_name}.csr ${CSR_DIR}/${domain_name}-${TODAY}.csr
    rsync -avz ${CERT_DIR}/${domain_name}.crt ${CERT_DIR}/${domain_name}-${TODAY}.crt
else
    echo -e "\e[1;31mCA签证失败！\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${domain_name} failed\n" >> ${ca_log}
    exit 1
fi

exit 0
