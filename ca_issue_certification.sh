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
