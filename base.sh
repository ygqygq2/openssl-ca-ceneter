#!/usr/bin/env bash
set -e
# 设置证书名
CA_NAME="my_CA"
CA_EMAIL="ca_admin@my.cn"
CA_DAYS="7300"
SERVER_DAYS="3650"

TODAY=$(date +%F)
KEY_DIR=${real_path}/private
CERT_DIR=${real_path}/certs
CSR_DIR=${real_path}/csrs
CONF_DIR=${real_path}/conf

[ ! -d ${KEY_DIR} ] && mkdir -p ${KEY_DIR}/
[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}/
[ ! -d ${CSR_DIR} ] && mkdir -p ${CSR_DIR}/
[ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR}/

function create_subj_info() {
    local domain_name
    domain_name=($*)
    domain_name=$(echo ${domain_name[*]}|sed 's@ @/CN=@g')
    SUBJ="/C=CN/ST=Guangdong/L=ZhuHai/O=my/OU=devops/CN=${domain_name}/emailAddress=${CA_EMAIL}"
}

function create_v3_req () {
    local domain_name
    domain_name=($*)
    local dns_index=1

    cat > v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
subjectKeyIdentifier = hash
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = critical,serverAuth,clientAuth
subjectAltName = @alt_names

[ alt_names ]
EOF

    for dn in ${domain_name[*]}; do
        echo "DNS.${dns_index} = ${dn}" >> v3.ext
        let dns_index++

        if [[ ! $dn =~ ^www\. ]]; then
            echo "DNS.${dns_index} = www.${dn}" >> v3.ext
            let dns_index++
        fi
    done
}
