#!/bin/bash  
##功能：测试各服务器能否免密登陆
##任小为 2018。05.21
##版本：v1.0

dir=$(cd "$(dirname "$0")"; pwd)
host=$dir/passwd.txt

for i in `awk '{print $1}' $host`;do
    user=`grep $i $host | awk '{print $3}'`
    ssh $user@$i "echo 'hello'" > /dev/null 2>&1
    if [ $? = 0 ];then
        echo -e "$i \033[32;49;1m **ok.** \033[31;49;0m \n"
    else
        echo -e "\033[31;49;1m $i can not access !!! \033[31;49;0m\n"
    fi
done

