#!/usr/bin/env bash
#此脚本用于生成服务器公私钥

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <domain>"
    echo "Example: sh $0 domain1 domain2"
    exit 1
fi

cert_name="$1"

# 产生站点证书请求 CSR 文件,此文件可下载,交给第三方 CA,颁发相关证书
create_subj_info $*
openssl req -newkey rsa:4096 -nodes -keyout ${KEY_DIR}/"${cert_name}".key -out ${CSR_DIR}/"${cert_name}".csr \
  -config ${real_path}/openssl.cnf -utf8 -days ${SERVER_DAYS} \
  -subj "${SUBJ}"

# 交由第三方CA机构颁发证书,则需要将生成的 csr 请求文件发给 CA 签发成证书
# -extfile v3.ext 使用外部扩展信息文件
# -extensions v3_ca 直接使用 openssl.cnf 中的配置
create_v3_req $*
openssl ca -config ${real_path}/openssl.cnf -utf8 -extfile v3.ext \
  -in ${CSR_DIR}/"${cert_name}".csr -cert ${CERT_DIR}/"${CA_NAME}".crt -keyfile ${KEY_DIR}/"${CA_NAME}".key -out ${CERT_DIR}/"${cert_name}".crt

# 添加 ca 到 server crt，形成证书链
#openssl x509 -in certs/harbor.linuxba.com.crt -outform PEM -out certs/harbor.linuxba.com.pem
cat ${CERT_DIR}/"${CA_NAME}".crt >> ${CERT_DIR}/"${cert_name}".crt

chmod 0600 ${KEY_DIR}/"${CA_NAME}".key

# backup
rsync -avz ${KEY_DIR}/"${cert_name}".key ${KEY_DIR}/${TODAY}-"${cert_name}".key
rsync -avz ${CSR_DIR}/"${cert_name}".csr ${CSR_DIR}/${TODAY}-"${cert_name}".csr
rsync -avz ${CERT_DIR}/"${cert_name}".crt ${CERT_DIR}/${TODAY}-"${cert_name}".crt
