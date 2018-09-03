#!/bin/bash
# func: analyze nginx access log for cc.
# version: v1.0
# auth: renxiaowei
# date: 2018.07.17

public(){
    echo ""
    read -p "请输入要分析的访问日志: " log_file
    echo ""

    if [ ! -f $log_file ];then
        echo -e "未找到: ${log_file} \n"
        exit 1
    fi

    if [ ! -s $log_file ];then
        echo -e "${log_file}是空文件 \n"
        exit 1
    fi

    top_num=10

    input_file=`echo $log_file | awk -F '/' '{print $(NF)}'`    
    analyze_dir=/tmp/nginx_log_analyze_cc
    top_time_file=$analyze_dir/ngx_log_top_time_${input_file}.txt
    
    mkdir -p $analyze_dir
    
    awk -F 'dateTime=' '{print $2}' $log_file | awk '{print $1}' | awk -F '[' '{print $2}' | sort | uniq -c | sort -rn | head -${top_num} > $top_time_file
}

cc(){
    #获取并发数最高的时间点z
    printf "\033[44;36m并发最高的前${top_num}个时间点: \033[0m \n"
    cat $top_time_file
    echo ""
    
    time_nums=`wc -l $top_time_file | awk '{print $1}'`
    
    for ((m=1; m<=$time_nums; m++))
    do
        time_num=`head -$m $top_time_file | tail -1 | awk '{print $2}'`
        top_time_file_tmp=$analyze_dir/ngx_log_top_time_${input_file}-$m.txt
        grep ${time_num} $log_file > $top_time_file_tmp
    
        echo -e "\033[32;49;1m在 $time_num : \033[31;49;0m \n"
    
        echo -e "\033[44;36m访问最多的前$top_num 个IP: \033[0m"
        awk -F "sourceAddress=" '{print $2}' $top_time_file_tmp | awk '{print $1}' | sort | uniq -c | sort -rn | head -${top_num}
    
        echo -e "\033[44;36m访问最多的前$top_num 个来源url: \033[0m"
        awk -F 'httpRerfer=' '{print $2}' $top_time_file_tmp | awk '{print $2}' | sort | uniq -c | sort -rn | head -${top_num}
    
        echo -e "\033[44;36m访问最多的前$top_num 个请求url: \033[0m"
        awk -F 'requestRInfo=' '{print $2}' $top_time_file_tmp | awk '{print $2}' | sort | uniq -c | sort -rn | head -${top_num}
    
        echo -e "\033[44;36m访问最多的前$top_num 个状态码: \033[0m"
        awk -F " responseCode=" '{print $2}' $top_time_file_tmp | cut -d " " -f1 | sort | uniq -c | sort -rn | head -${top_num}
        echo ""
    done
}

log_format(){
cat << EOF
log_format main 'WebAcessLogInformation dateTime="[\$time_local]" '
                'xForwardedFor="\$http_x_forwarded_for" sourceAddress=\$remote_addr '
                'dstAddress=\$server_addr dstHostName="\$server_name" dstPort="\$server_port" '
                'userAgent="\$http_user_agent" bytesOutInfo=\$bytes_sent sourceUserName="\$remote_user" '
                'responseCode=\$status httpRerfer="\$http_referer" logSessionNum="-" '
                'responseTimems=\$request_time responseTimes=- requestRInfo="\$request" ';
EOF
echo ""
}

case $1 in
    cc)
        public
        cc
        ;;

    help)
        echo ""
        echo -e "\033[44;36m1. 脚本使用方法: sh $0 { cc | help }\033[0m"
        echo -e "\033[44;36m   cc选项代表是否被cc分析; help代表帮助.\033[0m \n"
        echo -e "\033[44;36m2. 请确保日志必须为如下格式: \033[0m \n"
        log_format
        ;;

    *)
        echo ""
        echo -e $"Usage: $0 { cc | help }\n"
esac
exit 0
