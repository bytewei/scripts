# 自动分发ansible密钥

## 脚本简介
1. 本脚本主要用来统一自动分发ansible密钥（公钥）至目标服务器（“ansible客户端”），基于expect编写；<br>
2. 默认分发root账户的公钥，如果要分发非root账户密钥，可修改脚本“expect/scripts/expect.exp”第14行（set local_ssh_file "/root/.ssh/id_rsa.pub"）修改为其他密钥，例如：要分发nginx账户的密钥，nginx家目录在/home下，则第14行变量修改为：set local_ssh_file "/home/nginx/.ssh/id_rsa.pub"；<br>
3. 本脚本支持3个功能：<br>
   [1].检查服务器（IP）是否能ping通;<br>
   [2].分发公钥文件;<br>
   [3].一键检查目标服务器是否免认证。<br>
4. expect/expect.sh为脚本执行入口，在执行前请先编辑服务器文件：expect/conf/passwd.txt，行文格式分别为：服务器IP、ssh端口号、ssh账户、ssh密码；<br>

## 脚本结构
脚本目录如下：<br>
[renxiaowei]$ tree expect/<br>
expect/<br>
├── conf<br>
│   ├── check_ip.sh<br>
│   ├── check_ssh.sh<br>
│   └── passwd.txt<br>
├── expect.sh<br>
└── scripts<br>
    └── expect.exp<br>
[1]. expect.sh为脚本执行入口；<br>
[2]. scripts为核心脚本目录，scripts目录下的expect.exp为expect脚本，脚本中set部分为要用到的变量；<br>
[3]. conf为目标服务器配置文件（passwd.txt）、ip（check_ip.sh）及免密登陆(check_ssh.sh)检测脚本，其中IP及免密检测脚本不建议修改，目标服务器配置文件强烈建议修改，格式请见上文，每台服务器写一行；<br>

## 脚本使用方法
[1]. 下载本项目；<br>
[2]. cd expect;<br>
[3]. 编辑目标服务器文件：vim conf/passwd.txt;<br>
[4]. ./expect.sh 或者 sh expect.sh，然后根据提示依次执行即可。<br>

## 说明
正常情况下，只需要2不走，即编辑文件：conf/passwd.txt，然后执行脚本：./expect.sh，如果分发的不是root密钥，请修改scripts/expect.exp中的相关变量。<br>
