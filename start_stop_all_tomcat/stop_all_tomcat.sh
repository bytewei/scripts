#!/bin/bash
# 功能：停止所有tomcat服务
# 说明：本脚本可以通过任意一个用户执行

cur_time=`date +%Y%m%d_%H:%M:%S`
base=/home/tomcat-path
service_file=$base/.tomcat_service.txt
log_keys="Server startup"

echo "当前操作时间：$cur_time"

if [ ! -f $service_file ];then
    echo -e "\033[31;49;1m服务清单: ${service_file} 不存在 !!!\033[31;49;0m\n"
    exit 1
fi

count=0
for i in $(cat $service_file)
do
    ((count++))
    echo -e "\033[32;49;1mcount=$count\033[31;49;0m"

    if [ ! -d $base/$i ];then
        echo -e "\033[31;49;1mtomcat服务：$i 不存在 !!!\033[31;49;0m"
        continue
    fi

    echo "停止tomcat服务：$i ......"
    cd $base/$i/bin
    sh shutdown.sh

    echo "清理tomcat的temp和work缓存..."
    rm -rf $base/$i/work/*
    rm -rf $base/$i/temp/*
    #rm -rf $base/$i/logs/*
    #rm -rf $base/$i/webapps/ROOT
    echo ""

    if [ -f $base/$i/logs/catalina.out ];then
        sed -i "s@${log_keys}@Server_${cur_time}_startup@g" $base/$i/logs/catalina.out
    fi
done

ps -ef | grep "tomcat-" | grep -v grep | awk '{print $2}' | xargs kill -9

