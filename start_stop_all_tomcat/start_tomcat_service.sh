#!/bin/bash
# 功能：开启所有tomcat服务
# 说明：本脚本建议通过普通账户启动，建议通过脚本：start_all_tomcat.sh 调用

app=$1
base=/home/tomcat-path
service_file=$base/.tomcat_service.txt
time_inter=2
log_keys="Server startup in"
fail_log=/tmp/.tomcat_start_fail_origin.txt
sort_log=/tmp/tomcat_start_fail.txt

if [ ! -f $service_file ];then
    echo -e "\033[31;49;1m服务清单: ${service_file} 不存在 !!!\033[31;49;0m\n"
    exit 1
fi

echo "" > $fail_log

if [ ! "$app" ];then
    echo "请在脚本后面添加参数: 如：sh $0 tomcat-beike 或者 sh $0 all"
    exit 1
elif [ "$app"x == 'all'x ];then
    count=0
    for i in $(cat $service_file)
    do
        ((count++))
        echo -e "\033[32;49;1mcount=$count\033[31;49;0m"
    
        if [ ! -d $base/$i ];then
            echo -e "\033[31;49;1mtomcat服务：$i 不存在 !!!\033[31;49;0m"
            continue
        fi
    
        echo "开启tomcat服务: $i ......"
        if [ -f $base/$i/logs/catalina.out ];then
            sed -i "s@${log_keys}@Server_startup_in@g" $base/$i/logs/catalina.out
        fi

        sleep 2
        cd $base/$i/bin
        sh startup.sh
        for ((n=1;n<51;n++));do
            sleep ${time_inter}
            grep "$log_keys" $base/$i/logs/catalina.out
            if [ $? -eq 0 ];then
                echo ""
                break
            fi
            if [ $n == 50 ];then
                echo -e "\033[31;49;1m$i 启动超时，请参考日志：$sort_log ...\033[31;49;0m"
                echo "$i" >> $fail_log
                sort $fail_log | uniq > $sort_log
                break
            fi
        done
    done

else
    if [ ! -d $base/$app ];then
        echo -e "\033[31;49;1mtomcat服务：$i 不存在 !!!\033[31;49;0m"
        exit 1
    fi

    echo "开启tomcat服务: $app ......"
    if [ -f $base/$app/logs/catalina.out ];then
        sed -i "s@${log_keys}@Server_startup_in@g" $base/$app/logs/catalina.out
    fi

    sleep 2
    cd $base/$app/bin
    sh startup.sh
    for ((n=1;n<51;n++));do
        sleep ${time_inter}
    
        grep "$log_keys" $base/$app/logs/catalina.out
        if [ $? -eq 0 ];then
            echo ""
            break
        fi
        if [ $n == 50 ];then
            echo -e "\033[31;49;1m$app 启动超时，请参考日志：$sort_log ...\033[31;49;0m"
            echo "$app" >> $fail_log
            sort $fail_log | uniq > $sort_log
            break
        fi
    done
fi

