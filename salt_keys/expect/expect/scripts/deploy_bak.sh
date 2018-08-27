#!/bin/bash
##功能：部署脚本，适用于多salt-master情况下（本例为双主），放在目标服务器运行
##任小为 2017.07.20
##版本：v1.0

date="`date +%F`"
salt_master1="10.10.10.10"
salt_master2="10.10.10.20"
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

