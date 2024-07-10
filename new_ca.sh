#!/usr/bin/env bash
# 生成新的CA证书

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

# 防误操作
exit 0

#rsync -avz ${CONF_DIR}/openssl.cnf ${real_path}/openssl.cnf

# Generate the key.
# 生成私钥
openssl genrsa -out ${KEY_DIR}/${CA_NAME}.key 4096

create_subj_info ${CA_NAME}
openssl req -new -x509 -days ${CA_DAYS} -extensions v3_ca \
  -key ${KEY_DIR}/${CA_NAME}.key -out ${CERT_DIR}/${CA_NAME}.crt \
  -config ${real_path}/openssl.cnf -utf8 \
  -subj "${SUBJ}"

# Setup the first serial number for our keys... can be any 4 digit hex string... not sure if there are broader bounds but everything I've seen uses 4 digits.
echo AAAA > ${real_path}/serial

# Create the CA's key database.
cat /dev/null > ${real_path}/index.txt

# Create a Certificate Revocation list for removing 'user certificates.'
# 创建证书CRL列表,即证书黑名单
#openssl ca -gencrl -out ${CERT_DIR}/${CA_NAME}.crl -crldays 7

chmod 0600 ${KEY_DIR}/${CA_NAME}.key
[ ! -f ${real_path}/index.txt.attr ] && cat /dev/null > ${real_path}/index.txt.attr
[ ! -f ${CERT_DIR}/${CA_NAME}.srl ] && echo 01 > ${CERT_DIR}/${CA_NAME}.srl

# backup
rsync -avz ${KEY_DIR}/${CA_NAME}.key ${KEY_DIR}/${TODAY}-${CA_NAME}.key
rsync -avz ${CERT_DIR}/${CA_NAME}.crt ${CERT_DIR}/${TODAY}-${CA_NAME}.crt

