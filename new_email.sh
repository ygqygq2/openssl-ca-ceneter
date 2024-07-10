#!/usr/bin/env bash
#此脚本用于生成邮件签名证书

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <email-domain> <email>"
    echo "Example: sh $0 my.cn ca_admin@my.cn"
    exit 1
fi

#以姓名命名的目录,存放个人证书相关文件
email_dir=${real_path}/emails
domain_name=$1
email_name=$2
mkdir -p ${email_dir}/${email_name}/

create_subj_info $*
openssl req -new -newkey rsa:4096 -nodes -keyout ${email_dir}/"${email_name}".key -out ${email_dir}/"${email_name}".csr \
  -config ${real_path}/openssl.cnf -utf8 \
  -subj "${SUBJ}"

create_v3_email $email_name
openssl x509 -req -days ${SERVER_DAYS} -extfile v3.ext \
  -in ${email_dir}/"${email_name}".csr -CA ${CERT_DIR}/${CA_NAME}.crt -CAkey ${KEY_DIR}/${CA_NAME}.key -out ${email_dir}/"${email_name}".crt

# 打包为 pkcs12 格式
openssl pkcs12 -export -clcerts -in ${email_dir}/"${email_name}".crt -inkey ${email_dir}/"${email_name}".key -out ${email_dir}/"${email_name}".p12 -passin pass:1234 -password pass:1234

rsync -avz ${email_dir}/"${email_name}".key ${email_dir}/${email_name}/${email_name}-${TODAY}.key
rsync -avz ${email_dir}/"${email_name}".csr ${email_dir}/${email_name}/${email_name}-${TODAY}.csr
rsync -avz ${email_dir}/"${email_name}".crt ${email_dir}/${email_name}/${email_name}-${TODAY}.crt
rsync -avz ${email_dir}/"${email_name}".p12 ${email_dir}/${email_name}/${email_name}-${TODAY}.p12
