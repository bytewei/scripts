# 自动分发ansible密钥

## 脚本简介
1. 本脚本主要用来统一自动分发ansible密钥（公钥）至目标服务器（“ansible客户端”），基于expect编写；<br>
2. 默认分发root账户的公钥，如果要分发非root账户密钥，可修改脚本“expect/scripts/expect.exp”第14行（set local_ssh_file "/root/.ssh/id_rsa.pub"）修改为其他密钥，例如：要分发nginx账户的密钥，nginx家目录在/home下，则第14行变量修改为：set local_ssh_file "/home/nginx/.ssh/id_rsa.pub"；<br>
3. 本脚本支持3个功能：<br>
   [1].检查服务器（IP）是否能ping通;<br>
   [2].分发公钥文件;<br>
   [3].一键检查目标服务器是否免认证。<br>
4. expect/expect.sh为脚本执行入口，在执行前请先编辑服务器文件：expect/conf/passwd.txt，行文格式分别为：服务器IP、ssh端口号、ssh账户、ssh密码；<br>

