
###########################################
说明：本脚本适用于新服务器上架，ip配置完成后自动化操作。
目的：在各服务器自动化安装salt-minion，通过salt控制各服务器（日常维护及部署各服务等）
条件：1.本脚本需要放在salt-master上执行；
      2.除passwd.txt文件外，不建议修改其他文件。
执行方式：1.如果环境中只有1台master节点，定义salt-master节点，编辑scripts/deploy.sh,修改"salt_master"常量值；
            如果环境中有2个master节点（双主），则将scripts/deploy_bak.sh修改为scripts/deploy.sh，并修改常量"salt_master1"及"salt_master2";
            请参考下面“注意”第6、7条。
          2.定义目标服务器，编辑conf/passwd.txt,填写需要操作的目标服务器信息，每台机器占一行；
            请参考下面“注意”第5条。
          3.执行脚本，如下：
            [root]# sh $dir/expect.sh | tee /tmp/expect_log.txt 
            请参考下面“注意”第1、2、3条。

##########################################
详细说明：
原理：
1.通过expect工具，将需要的文件或脚本从本地（salt-master服务器）传输到各目标服务器上。
2.通过expect工具，远程执行各目标服务器脚本（deploy.sh），并将过程打印到屏幕上。
3.待deploy.sh脚本执行成功后，在本地（salt-master）服务器上执行下面命令：
  [root]# salt-key -L    ##列出所有已注册、未注册服务
  [root]# salt-key -A    ##执行该命令后，输入y，注册所有服务器
4.待所有服务器注册成功后，剩下工作交由salt执行（通过salt-master控制salt-minion）

##########################################
注意：
1.本系列脚本包含下列文件：
.
├── conf
│   ├── check_ip.sh
│   └── passwd.txt
├── expect.sh
└── scripts
    ├── deploy.sh
    ├── epel-release-latest-6.noarch.rpm
    └── expect.exp

2.执行脚本为：expect.sh。

3.为了方便查看操作结果，请把日志打出，建议执行:
  [root]# $dir/expect.sh | tee /tmp/expect_log.txt 
或者：
  [root]# cd $dir
  [root]# ./expect.sh | tee /tmp/expect_log.txt

4.check_ip.sh与passwd.txt文件要放在conf目录

5.passwd.txt文件内容格式为：
[root]# cat conf/passwd.txt
        127.0.0.1 22 root Passwd@201707
对应的解释为：
服务器IP 服务器登录端口 服务器登录账户 服务器登录账户对应的密码
如果要批量操作多台机器，则每台机器信息为一行

6.如果环境中只有一台salt-master，则deploy.sh脚本应为：
[root]# cat scripts/deploy.sh
#!/bin/bash

date="`date +%F`"
salt_master="10.200.138.55"
epel_file="/usr/local/weihu/epel-release-latest-6.noarch.rpm"
minion_conf="/etc/salt/minion"
minion_id="`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`"

install_minion(){
    echo "install epel"
    rpm -ivh $epel_file
    echo "yum install salt-minion"
    yum install -y salt-minion
}

bak_minon_conf(){
    echo "backup salt-minion config file"
    \cp -p $minion_conf ${minion_conf}_$date
    echo "empty salt-minon config file"
    echo "" > $minion_conf
}

config(){
    echo "config master: $salt_master"
    echo "master: $salt_master" >> $minion_conf
    echo "config id: $minion_id"
    echo "id: $minion_id" >> $minion_conf
}

start_minon(){
    echo "start salt-minion"
    /etc/init.d/salt-minion restart
}

install_minion
bak_minon_conf
config
start_minon

7.如果环境中只有多台salt-master（如：2台），则deploy.sh脚本应为：
[root]# cat scripts/deploy.sh
#!/bin/bash

date="`date +%F`"
salt_master1="1.1.1.1"
salt_master2="2.2.2.2"
epel_file="/usr/local/weihu/epel-release-latest-6.noarch.rpm"
minion_conf="/etc/salt/minion"
minion_id="`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`"

install_minion(){
    echo "install epel"
    rpm -ivh $epel_file
    echo "yum install salt-minion"
    yum install -y salt-minion
}

bak_minon_conf(){
    echo "backup salt-minion config file"
    \cp -p $minion_conf ${minion_conf}_$date
    echo "empty salt-minon config file"
    echo "" > $minion_conf
}

config(){
    echo "config master: $salt_master"
    echo "master: " >> $minion_conf
    echo "  - $salt_master1" >> $minion_conf
    echo "  - $salt_master2" >> $minion_conf
    echo "config id: $minion_id"
    echo "id: $minion_id" >> $minion_conf
}

start_minon(){
    echo "start salt-minion"
    /etc/init.d/salt-minion restart
}

install_minion
bak_minon_conf
config
start_minon

8.传输的文件（脚本）会放在目标服务器的/usr/local/weihu/目录（自动创建该目录）；
  本脚本中deploy.sh适用于单台salt-master，deploy_bak.sh适用于多salt-master（双主）中；
  本脚本中涉及到的ip、密码等均为虚假的，请配置好scripts/deploy.sh中的master ID(ip)及conf/passwd.txt中的目标服务器信息后再执行脚本；
  本脚本中涉及的minion ID均是服务器eth0网卡ip，如果要更换ID，请修改脚本scripts/deploy.sh，或者脚本执行成功后，通过salt-master再次设置minion ID
  操作前，请确保目标服务器能上互联网。

###########################################

--任小为
--2017.07.20
