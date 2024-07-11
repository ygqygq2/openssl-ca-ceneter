# openssl 证书签发脚本

功能：
* 生成 CA 证书
* 生成 server 证书
* 生成 client 证书
* 生成 email 签名证书
* 验证证书
* 使用 csr 签发证书

## 使用
> * rhel 系目录为 `/etc/pki/tls`；
> * ubuntu 目录为 `/etc/ssl`；

备份 `/etc/pki/tls`，然后把整个仓库脚本和 openssl.cnf 放进去就可以使用了。

```
[root@ygqygq2 tls]# ls
autoanswer.exp  ca_issue_certification.sh   ca_verify_certification.sh  conf       new_ca.sh      new_email.sh   openssl.cnf  serial
base.sh         ca_revoke_certification.sh  ca_verify.sh                index.txt  new_client.sh  new_server.sh  README.md    verify.sh
[root@master1 tls]# pwd
/etc/pki/tls
[root@ygqygq2 tls]# 
```
