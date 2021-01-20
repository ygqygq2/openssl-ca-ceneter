#!/usr/bin/env bash
#此脚本用于生成用户使用的证书，即导入浏览器用于验证的证书

# 设置ca证书名
ca_name="my_CA"

# get pwd
cd `dirname $0`
real_path=`pwd`
today=$(date +%F)
key_dir=${real_path}/private
cert_dir=${real_path}/certs
conf_dir=${real_path}/conf
user_dir=${real_path}/users

[ ! -d ${key_dir} ] && mkdir -p ${key_dir}/
[ ! -d ${cert_dir} ] && mkdir -p ${cert_dir}/
[ ! -d ${conf_dir} ] && mkdir -p ${conf_dir}/
[ ! -d ${user_dir} ] && mkdir -p ${user_dir}/

#以姓名命名的目录,存放个人证书相关文件
user_name=$1
mkdir -p ${user_dir}/${user_name}/

#用DES3的算法产生公私钥对,并设定密钥长度为4096位
#openssl genrsa -des3 -out ${user_dir}/client.key 4096
openssl genrsa -des3 -out ${user_dir}/client.key -passout pass:1234 4096 -utf8

#产生证书申请CSR文件(证书请求),此文件可下载,交给第三方CA(比如CFCA,VerisginCA),颁发相关证书
openssl req -new -key ${user_dir}/client.key -out ${user_dir}/client.csr -passin pass:1234 -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=my/OU=devops/CN=${user_name}/emailAddress=ca_admin@my.cn" -utf8

#openssl req -new -key ${user_dir}/client.key -out ${user_dir}/client.csr -config ${conf_dir}/client.cnf -utf8

#用CA的私钥给证书请求文件签名,生成相关证书文件(CRT格式,与传统的CER文件一样,包含证书的主体、公钥以及CA的签名)
#会提示输入密码,此密码为CA机构的证书(根证书或者二级证书)的密码
openssl ca -in ${user_dir}/client.csr -cert ${cert_dir}/${ca_name}.crt -keyfile ${key_dir}/${ca_name}.key -out ${user_dir}/client.crt

#以PKCS12格式导出证书,导出时,可自由设定证书保护密码,这样一来,即便别人拿到此证书,没有密码也没法安装
#安装:用户可将此文件安装到IE浏览器内,操作方法:双击证书文件,一路下一步即可
#安装完成后,可点击"工具"-->"Internet选项"-->"内容"-->"证书",查看是否已存在刚刚安装的证书
#openssl pkcs12 -export -clcerts -in ${user_dir}/client.crt -inkey ${user_dir}/client.key -out ${user_dir}/client.p12
openssl pkcs12 -export -clcerts -in ${user_dir}/client.crt -inkey ${user_dir}/client.key -out ${user_dir}/client.p12 -passin pass:1234 -password pass:1234

rsync -avz ${user_dir}/client.key ${user_dir}/${user_name}/${user_name}_${today}.key
rsync -avz ${user_dir}/client.csr ${user_dir}/${user_name}/${user_name}_${today}.csr
rsync -avz ${user_dir}/client.crt ${user_dir}/${user_name}/${user_name}_${today}.crt
rsync -avz ${user_dir}/client.p12 ${user_dir}/${user_name}/${user_name}_${today}.p12
