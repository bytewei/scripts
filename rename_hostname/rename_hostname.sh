#!/bin/bash
# 功能：一键修改服务器主机名，仅支持centos6
# 作者：任小为 renxiaowei@cnstrong.cn
# version: v2.0

hosts_file=/etc/hosts
sys_network=/etc/sysconfig/network
current_name=`hostname`
hosts_line="`grep '^127.0.0.1' /etc/hosts | grep $current_name`"

#获取要修改的主机名
read -p "请输入修改后的主机名：" name
if [ ! $name ];then
    echo "你没有输入主机名称"
    exit 1
fi

set_name6(){
    echo "当前主机名称：$current_name, 要修改成名称：$name ..."
    echo "设置hostname ......[ok]"
    hostname $name
}


set_name7(){
    echo "当前主机名称：$current_name, 要修改成名称：$name ..."
    echo "设置hostname ......[ok]"
    hostnamectl set-hostname $name
}
add_hosts(){
    echo "添加hosts记录 ......[ok]"
    echo "127.0.0.1   $name" >> $hosts_file
}

del_hosts(){
    echo "删除hosts记录：$hosts_line"
    sed -i "/$hosts_line/d" $hosts_file
}

alter_hosts(){
    echo "检测hosts记录 ..."
    grep "$name" $hosts_file > /dev/null
    if [ $? -ne 0 ];then
        if [ "${current_name}"x == "localhost"x ] || [ "${current_name}"x == "localhost.localdomain"x ];then
            add_hosts
        else
            del_hosts
            add_hosts
        fi
    else
        del_hosts
        echo "hosts记录中\"127.0.0.1   $name\"解析关系已存在"
    fi
}

alter_sys_network(){
    echo "检测 /etc/sysconfig/network 配置 ..."
    grep "HOSTNAME=$name" $sys_network > /dev/null
    if [ $? -ne 0 ];then
        echo "修改 /etc/sysconfig/network 配置 ......[ok]"
        sed -i '/HOSTNAME=/d' $sys_network
        sed -i "/NETWORKING=yes/a HOSTNAME=$name" $sys_network
    else
        echo "/etc/sysconfig/network已包含 $name 配置"
    fi
}

main(){
    kernel=`uname -r`
    os=`cat /etc/redhat-release`
    echo "服务器操作系统：$os"

    echo $kernel | grep '^2.6' > /dev/null
    if [ $? -eq 0 ];then
        set_name6
        alter_hosts
        alter_sys_network
    else
        echo $kernel | grep '^3.' > /dev/null
        if [ $? -eq 0 ];then
            set_name7
            alter_hosts
        else
            echo "当前服务器不是centos系列，内核版本：$kernel"
            exit 1
        fi
    fi
}

main

