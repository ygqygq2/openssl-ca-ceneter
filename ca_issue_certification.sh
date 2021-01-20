#!/bin/bash

server_flag=$1
agent=$(echo ${server_flag}|awk -F_ '{print $1}')
server_id=$(echo ${server_flag}|awk -F_ '{print $2}')

# get pwd
cd `dirname $0`
real_path=`pwd`
today=$(date +%F)
key_dir=${real_path}/private/${agent}
cert_dir=${real_path}/certs/${agent}
csr_dir=${real_path}/csrs/${agent}
newcert_dir=${real_path}/newcerts/	#自动生成证书路径，openssl.cnf中配置的（相当于备份）
conf_dir=${real_path}/conf
ca_log=${real_path}/ca_issue_certification.log

[ ! -d ${key_dir} ] && mkdir -p ${key_dir}/
[ ! -d ${cert_dir} ] && mkdir -p ${cert_dir}/
[ ! -d ${csr_dir} ] && mkdir -p ${csr_dir}/
[ ! -d ${newcert_dir} ] && mkdir -p ${newcert_dir}/
[ ! -d ${conf_dir} ] && mkdir -p ${conf_dir}/

[ ! -f ${csr_dir}/${server_flag}.csr ] && { echo -e "\e[1;31m缺少请求文件！\e[0m" ; exit 1 ; }

check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
until [[ -z "${check_autoanswer_pid}" ]];do
        echo -e "CA签证排队中......" && sleep 5
        check_autoanswer_pid=$(ps aux|grep "autoanswer"|grep -v "grep"|awk '{print $2}')
done

/usr/bin/expect ${real_path}/autoanswer.exp ${agent} ${server_id}
if [ $? -eq 0 ] ;then
	echo -e "\e[1;32mCA签证成功。\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${server_flag} successed\n" >> ${ca_log}
	rsync -avz ${csr_dir}/${server_flag}.csr ${csr_dir}/${server_flag}_${today}.csr
	rsync -avz ${cert_dir}/${server_flag}.crt ${cert_dir}/${server_flag}_${today}.crt
else
	echo -e "\e[1;31mCA签证失败！\e[0m" && echo -e "$(date +%F-%T)\tca issue certification to ${server_flag} failed\n" >> ${ca_log}
	exit 1
fi

exit 0
