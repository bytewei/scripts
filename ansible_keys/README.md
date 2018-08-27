# 自动分发ansible密钥

## 脚本简介
1. 本脚本主要用来统一自动分发ansible密钥（公钥）至服务器端（“ansible客户端”），基于expect编写；<br>
2. 默认分发root账户的公钥，如果要分发非root账户密钥，可修改脚本“expect/scripts/expect.exp”第14行（set local_ssh_file "/root/.ssh/id_rsa.pub"）修改为其他密钥，例如：要分发nginx账户的密钥，nginx家目录在/home下，则第14行变量修改为：set local_ssh_file "/home/nginx/.ssh/id_rsa.pub"；<br>
