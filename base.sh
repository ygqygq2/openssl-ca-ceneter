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
    local domain_name=()
    local email_name="$CA_EMAIL" # 默认使用环境变量CA_EMAIL作为邮件名

    # 遍历所有参数
    for arg in "$@"; do
        if [[ "$arg" == *@* ]]; then
            email_name="$arg" # 如果参数包含@，则认为是邮件名
        else
            domain_name+=("$arg") # 否则，认为是域名
        fi
    done

    # 将域名数组转换为以"/CN="分隔的字符串
    local domain_str=$(IFS=/CN=; echo "${domain_name[*]}")
    domain_str="/CN=$domain_str" # 添加前缀以符合SUBJ格式

    # 构造SUBJ字符串
    SUBJ="/C=CN/ST=Guangdong/L=ZhuHai/O=my/OU=devops${domain_str}/emailAddress=${email_name}"
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

function create_v3_email () {
    local email_name
    email=$1

    cat > v3.ext <<EOF
[ v3_email ]
basicConstraints = critical,CA:FALSE
subjectKeyIdentifier = hash
keyUsage = nonRepudiation,digitalSignature,keyEncipherment,dataEncipherment
extendedKeyUsage = critical,emailProtection
subjectAltName = critical,email:${email_name}
EOF
}
