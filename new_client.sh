#!/usr/bin/env bash
#此脚本用于生成用户使用的证书，即导入浏览器用于验证的证书

# get pwd
cd $(dirname $0)
real_path=$(pwd)

. $real_path/base.sh

if [ $# -eq 0 ]; then
    echo "Usage: sh $0 <username>"
    echo "Example: sh $0 user1"
    exit 1
fi

#以姓名命名的目录,存放个人证书相关文件
user_dir=${real_path}/users
user_name=$1
mkdir -p ${user_dir}/${user_name}/

# 用DES3的算法产生公私钥对,并设定密钥长度为4096位
openssl genrsa -des3 -out ${user_dir}/client.key -passout pass:1234 4096 -utf8

create_subj_info $user_name
openssl req -new -key ${user_dir}/client.key -out ${user_dir}/client.csr -passin pass:1234 \
  -subj "${SUBJ}" -utf8

# 会提示输入密码,此密码为 CA 机构的证书(根证书或者二级证书)的密码
openssl ca -in ${user_dir}/client.csr -cert ${CERT_DIR}/${CA_NAME}.crt -keyfile ${KEY_DIR}/${CA_NAME}.key -out ${user_dir}/client.crt

#以PKCS12格式导出证书,导出时,可自由设定证书保护密码,这样一来,即便别人拿到此证书,没有密码也没法安装
#安装:用户可将此文件安装到IE浏览器内,操作方法:双击证书文件,一路下一步即可
#安装完成后,可点击"工具"-->"Internet选项"-->"内容"-->"证书",查看是否已存在刚刚安装的证书
openssl pkcs12 -export -clcerts -in ${user_dir}/client.crt -inkey ${user_dir}/client.key -out ${user_dir}/client.p12 -passin pass:1234 -password pass:1234

rsync -avz ${user_dir}/client.key ${user_dir}/${user_name}/${user_name}_${TODAY}.key
rsync -avz ${user_dir}/client.csr ${user_dir}/${user_name}/${user_name}_${TODAY}.csr
rsync -avz ${user_dir}/client.crt ${user_dir}/${user_name}/${user_name}_${TODAY}.crt
rsync -avz ${user_dir}/client.p12 ${user_dir}/${user_name}/${user_name}_${TODAY}.p12
