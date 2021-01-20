#!/bin/bash

server_flag=$1

# get pwd
cd `dirname $0`
real_path=`pwd`
today=$(date +%F)
key_dir=${real_path}/private
cert_dir=${real_path}/certs
conf_dir=${real_path}/conf

[ ! -d ${key_dir} ] && mkdir -p ${key_dir}/
[ ! -d ${cert_dir} ] && mkdir -p ${cert_dir}/
[ ! -d ${conf_dir} ] && mkdir -p ${conf_dir}/

openssl ca -in ${cert_dir}/${server_flag}.csr -cert ${cert_dir}/my_CA.crt -keyfile ${key_dir}/my_CA.key -out ${cert_dir}/${server_flag}.crt

/bin/cp ${cert_dir}/${server_flag}.csr ${cert_dir}/${server_flag}_${today}.csr
/bin/cp ${cert_dir}/${server_flag}.crt ${cert_dir}/${server_flag}_${today}.crt


