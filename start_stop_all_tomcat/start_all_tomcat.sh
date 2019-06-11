#!/bin/bash
# 功能：调用start_tomcat_service.sh，切换普通账户开启所有tomcat

##定位脚本所在当前目录
dir=$(cd "$(dirname "$0")"; pwd)

base=/home/tomcat-path
start_script=$dir/start_tomcat_service.sh
service_file=$base/.tomcat_service.txt
user=alpha
id_user=`id | awk '{print $1}'| awk -F "(" '{print $2}'| awk -F ")" '{print $1}'`

if [ ! -f $start_script ];then
    echo "启动脚本：$start_script 不存在 !!!"
fi

if [ ! -f $service_file ];then
    echo -e "\033[31;49;1m服务清单: ${service_file} 不存在 !!!\033[31;49;0m\n"
    exit 1
fi

id $user > /dev/null 2>&1
if [ $? -ne 0 ];then
    echo "创建账户: $user..."
    useradd $user
fi

for i in $(cat $service_file)
do
    if [ ! -d $base/$i ];then
        echo -e "\033[31;49;1mtomcat服务：$i 不存在 !!!\033[31;49;0m"
        exit 1
    fi

    chown $user -R $base/$i
done

chown $user $start_script

if [ $id_user == "root" ];then
    echo "当前运行账户为: root"
    su - $user -s /bin/bash $start_script all
else
    if [ $id_user == "$user" ];then
        echo "当前运行账户为: $user"
	sh $start_script all
    else
        echo "当前运行账户既不是root也不是$user"
	exit 1
    fi
fi

