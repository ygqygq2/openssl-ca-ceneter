#!/bin/bash

server_flag=$1

# get pwd
cd `dirname $0`
real_path=`pwd`
TODAY=$(date +%F)
KEY_DIR=${real_path}/private
CERT_DIR=${real_path}/certs
CONF_DIR=${real_path}/conf

[ ! -d ${KEY_DIR} ] && mkdir -p ${KEY_DIR}/
[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}/
[ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR}/

openssl ca -in ${CERT_DIR}/${server_flag}.csr -cert ${CERT_DIR}/my_CA.crt -keyfile ${KEY_DIR}/my_CA.key -out ${CERT_DIR}/${server_flag}.crt

/bin/cp ${CERT_DIR}/${server_flag}.csr ${CERT_DIR}/${server_flag}_${TODAY}.csr
/bin/cp ${CERT_DIR}/${server_flag}.crt ${CERT_DIR}/${server_flag}_${TODAY}.crt


