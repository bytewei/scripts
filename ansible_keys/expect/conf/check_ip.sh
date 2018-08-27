#!/bin/bash  
##功能：测试各服务器网络是否通
##任小为 2017.07.20
##版本：v1.0

dir=$(cd "$(dirname "$0")"; pwd)
host=$dir/passwd.txt

for i in `awk '{print $1}' $host`;do
    ping -i 0.1 -c 3 $i > /dev/null 2>&1
    if [ $? = 0 ];then
        echo -e "$i \033[32;49;1m **ok.** \033[31;49;0m \n"
    else
        echo -e "\033[31;49;1m $i can not access !!! \033[31;49;0m\n"
    fi
done

