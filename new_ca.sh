#!/usr/bin/env bash
# 生成新的CA证书

# 设置证书名
ca_name="my_CA"

# get pwd
cd `dirname $0`
real_path=`pwd`
today=$(date +%F)
key_dir=${real_path}/private
cert_dir=${real_path}/certs
conf_dir=${real_path}/conf

[ ! -d ${CA_dir} ] && mkdir -p ${CA_dir}/
[ ! -d ${key_dir} ] && mkdir -p ${key_dir}/
[ ! -d ${cert_dir} ] && mkdir -p ${cert_dir}/
[ ! -d ${conf_dir} ] && mkdir -p ${conf_dir}/

#防误操作
exit 0

# 先恢复默认openssl.cnf配置
rsync -avz ${conf_dir}/openssl.cnf.default ${real_path}/openssl.cnf

# Generate the key.
#在本地产生公私钥对
openssl genrsa -out ${key_dir}/${ca_name}.key 4096 -utf8

# Generate a certificate request.
#根据公私钥对产生一个证书请求文件----CSR文件( -subj 和 -config 生成出来的请求文件编码不一样，原因还未查到 )
openssl req -new -key ${key_dir}/${ca_name}.key -out ${cert_dir}/${ca_name}.csr -subj "/C=CN/ST=Guangdong/L=ZhuHai/O=my/OU=${ca_name}/CN=${ca_name}/emailAddress=ca_admin@my.cn" -utf8
#openssl req -new -key ${key_dir}/${ca_name}.key -out ${cert_dir}/${ca_name}.csr -config "${conf_dir}/ca.cnf"

# Self signing key is bad... this could work with a third party signed key... registeryfly has them on for $16 but I'm too cheap lazy to get one on a lark.
# I'm also not 100% sure if any old certificate will work or if you have to buy a special one that you can sign with. I could investigate further but since this
# service will never see the light of an unencrypted Internet see the cheap and lazy remark.
# So self sign our root key.
#用自己的私钥对CSR文件进行签名-----即为自签名证书,并生成国际通用的x509格式证书,有效期为10年
openssl x509 -req -days 7300 -in ${cert_dir}/${ca_name}.csr -signkey ${key_dir}/${ca_name}.key -out ${cert_dir}/${ca_name}.crt 

# Setup the first serial number for our keys... can be any 4 digit hex string... not sure if there are broader bounds but everything I've seen uses 4 digits.
echo AAAA > ${real_path}/serial

# Create the CA's key database.
cat /dev/null > ${real_path}/index.txt

# 替换默认openssl.cnf配置
rsync -avz ${conf_dir}/openssl.cnf ${real_path}/openssl.cnf

# Create a Certificate Revocation list for removing 'user certificates.'
#创建证书CRL列表,即证书黑名单
#openssl ca -gencrl -out ${cert_dir}/${ca_name}.crl -crldays 7

rsync -avz ${key_dir}/${ca_name}.key ${key_dir}/${today}_${ca_name}.key
rsync -avz ${cert_dir}/${ca_name}.csr ${cert_dir}/${today}_${ca_name}.csr
rsync -avz ${cert_dir}/${ca_name}.crt ${cert_dir}/${today}_${ca_name}.crt
