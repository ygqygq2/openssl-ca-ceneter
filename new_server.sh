#!/usr/bin/env bash
#此脚本用于生成服务器公私钥

# 设置ca证书名
ca_name="my_CA"
# 设置签发域名
domain_name=($*)
domain_name=$(echo ${domain_name[*]}|sed 's@ @/CN=@g')

# get pwd
cd `dirname $0`
real_path=`pwd`
today=$(date +%F)
key_dir=${real_path}/private
cert_dir=${real_path}/certs
csr_dir=${real_path}/csrs
conf_dir=${real_path}/conf

[ -z "$1" ] && echo "脚本请接域名为参数" && exit 1
[ ! -d ${key_dir} ] && mkdir -p ${key_dir}/
[ ! -d ${cert_dir} ] && mkdir -p ${cert_dir}/
[ ! -d ${csr_dir} ] && mkdir -p ${csr_dir}/
[ ! -d ${conf_dir} ] && mkdir -p ${conf_dir}/

#产生站点证书的公私钥对（提供服务的服务器上生成）
#openssl genrsa -out ${key_dir}/server.key 2048 -utf8
#产生站点证书请求CSR文件,此文件可下载,交给第三方CA(比如CFCA,VerisginCA),颁发相关证书（提供服务的服务器上生成）
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${key_dir}/server.key -out ${csr_dir}/server.csr \
-subj "/C=CN/ST=Guangdong/L=ZhuHai/O=my/OU=devops/CN=${domain_name}/emailAddress=ca_admin@my.cn" \
-utf8
#openssl req -new -key ${key_dir}/server.key -out ${csr_dir}/server.csr -config "${conf_dir}/server_utf8.cnf" -utf8

#用自建CA的私钥给证书请求文件签名,生成相关证书文件(CRT格式,与传统的CER文件一样,包含证书的主体、公钥以及CA的签名)
#交由第三方CA机构颁发证书,则需要将生成的csr请求文件发给CA签发成证书
openssl ca -in ${csr_dir}/server.csr -cert ${cert_dir}/${ca_name}.crt -keyfile ${key_dir}/${ca_name}.key -out ${cert_dir}/server.crt

rsync -avz ${key_dir}/server.key ${key_dir}/${today}_server.key
rsync -avz ${csr_dir}/server.csr ${csr_dir}/${today}_server.csr
rsync -avz ${cert_dir}/server.crt ${cert_dir}/${today}_server.crt
