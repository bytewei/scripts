#!/bin/bash
# func: analyze nginx access log.
# version: v1.2
# auth: renxiaowei
# date: 2018.07.11

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
    analyze_dir=/tmp/nginx_log_analyze
    top_ip_file=$analyze_dir/ngx_log_top_ip_${input_file}.txt
    top_src_url_file=$analyze_dir/ngx_log_top_src_url_${input_file}.txt
    top_dest_url_file=$analyze_dir/ngx_log_top_dest_url_${input_file}.txt
    top_code_file=$analyze_dir/ngx_log_top_code_${input_file}.txt
    
    mkdir -p $analyze_dir
    
    start_time=`head -1 $log_file | awk '{print $2}'|cut -d "[" -f2`
    end_time=`tail -1 $log_file | awk '{print $2}'|cut -d "[" -f2`
    total_nums=`wc -l $log_file | awk '{print $1}'`
    size=`du -sh $log_file | awk '{print $1}'`
    
    #获取起始与截止时间
    echo -e "访问起始时间: $start_time ; 截止时间: $end_time \n"
    
    #获取总行数与大小
    echo -e "共访问 $total_nums 次 ; 日志大小: $size \n"

    #获取最活跃IP
    awk -F "sourceAddress=" '{print $2}' $log_file | awk '{print $1}' | sort | uniq -c | sort -rn | head -${top_num} > $top_ip_file

    #获取访问来源最多的url
    awk -F "httpRerfer=" '{print $2}' $log_file | awk -F '"' '{print $2}' | sort | uniq -c | sort -rn | head -${top_num} > $top_src_url_file

    #获取请求最多的url
    awk -F 'requestRInfo=' '{print $2}' $log_file | awk '{print $2}' | sort | uniq -c | sort -rn | head -${top_num} > $top_dest_url_file

    #获取返回最多的状态码
    awk -F " responseCode=" '{print $2}' $log_file | cut -d " " -f1 | sort | uniq -c | sort -rn | head -${top_num} > $top_code_file
}

simple(){
    echo -e "\033[44;36m+-+-+-+-+-+- 下面是粗略分析 +-+-+-+-+-+-\033[0m \n"
    
    #获取最活跃IP
    printf "\033[44;36m最活跃的前${top_num}个访问IP: \033[0m \n"
    cat $top_ip_file
    echo ""
    
    #获取访问来源最多的url
    printf "\033[44;36m访问来源最多的前${top_num}个url: \033[0m \n"
    cat $top_src_url_file
    echo ""
    
    #获取请求最多的url
    printf "\033[44;36m请求最多的前${top_num}个url: \033[0m \n"
    cat $top_dest_url_file
    echo ""
    
    #获取返回最多的状态码
    printf "\033[44;36m返回最多的前${top_num}个状态码: \033[0m \n"
    cat $top_code_file
    echo ""
}

detail(){
    echo -e "\033[44;36m+-+-+-+-+-+- 下面是详细分析 +-+-+-+-+-+-\033[0m \n"
    
    printf "\033[44;36m最活跃的前${top_num}个访问IP详情: \033[0m \n"
    ip_nums=`wc -l $top_ip_file | awk '{print $1}'`
    for ((i=1; i<=$ip_nums; i++))
    do
        ip_num=`head -$i $top_ip_file | tail -1 | awk '{print $1}'`
        ip_addr=`head -$i $top_ip_file | tail -1 | awk '{print $2}'`
        ip_percent=`awk 'BEGIN { printf "%.1f%",('$ip_num'/'$total_nums')*100 }'`
        #分别计算访问最多的url所占百分比
        echo ""
        echo -e "共有来自 ${ip_addr} 的 ${ip_num} 条访问，占比:\033[31;49;1m ${ip_percent} \033[31;49;0m \n"
        #分别计算每个访问最多的IP的最多来源url
        echo -e "\033[32;49;1m+=+=+=+= ${ip_addr} \033[31;49;0m访问来源最多的前${top_num}个url: "
        grep ${ip_addr} $log_file | awk -F "httpRerfer=" '{print $2}' | awk -F '"' '{print $2}' | sort | uniq -c | sort -rn | head -${top_num}
        echo ""
        #分别计算每个请求最多的IP的最多来源url
        echo -e "\033[32;49;1m#+#+#+#+\033[31;49;0m${ip_addr}请求最多的前${top_num}个url: "
        grep ${ip_addr} $log_file | awk -F 'requestRInfo=' '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -rn | head -${top_num}
    done
    
    echo ""
    printf "\033[44;36m访问来源最多的前${top_num}个url详情: \033[0m \n"
    url_src_nums=`wc -l $top_src_url_file | awk '{print $1}'`
    for ((k=1; k<=$url_src_nums; k++))
    do
        url_src_num=`head -$k $top_src_url_file | tail -1 | awk '{print $1}'`
        url_src_addr=`head -$k $top_src_url_file | tail -1 | awk '{print $2}'`
        url_src_percent=`awk 'BEGIN { printf "%.1f%",('$url_src_num'/'$total_nums')*100 }'`
        #分别计算访问来源最多的url所占百分比
        echo ""
        echo -e "共有 ${url_src_num} 条 ${url_src_addr} 的访问，占比:\033[31;49;1m ${url_src_percent} \033[31;49;0m \n"
        #分别计算每个访问来源最多的url的最多ip
        echo -e "\033[32;49;1m#-#-#-#-\033[31;49;0m${url_src_addr}访问最多的前${top_num}个ip: "
        grep "${url_src_addr}" $log_file | awk -F 'sourceAddress=' '{print $2}' | awk '{print $1}' |sort | uniq -c | sort -rn | head -${top_num}
    done
    
    echo ""
    printf "\033[44;36m请求最多的前${top_num}个url详情: \033[0m \n"
    url_dest_nums=`wc -l $top_dest_url_file | awk '{print $1}'`
    for ((j=1; j<=$url_dest_nums; j++))
    do
        url_dest_num=`head -$j $top_dest_url_file | tail -1 | awk '{print $1}'`
        url_dest_addr=`head -$j $top_dest_url_file | tail -1 | awk '{print $2}'`
        url_dest_percent=`awk 'BEGIN { printf "%.1f%",('$url_dest_num'/'$total_nums')*100 }'`
        #分别计算访问请求最多的url所占百分比
        echo ""
        echo -e "共有 ${url_dest_num} 条 ${url_dest_addr} 请求的访问，占比:\033[31;49;1m ${url_dest_percent} \033[31;49;0m \n"
        #分别计算每个访问请求最多的url的最多ip
        echo -e "\033[32;49;1m#.#.#.#.\033[31;49;0m${url_dest_addr}访问最多的前${top_num}个ip: "
        grep "${url_dest_addr}" $log_file | awk -F 'sourceAddress=' '{print $2}' | awk '{print $1}' |sort | uniq -c | sort -rn | head -${top_num}
    done
    
    echo ""
    printf "\033[44;36m返回最多的前${top_num}个状态码详情: \033[0m \n"
    code_nums=`wc -l $top_code_file | awk '{print $1}'`
    for ((h=1; h<=$code_nums; h++))
    do
        code_num=`head -$h $top_code_file | tail -1 | awk '{print $1}'`
        code_name=`head -$h $top_code_file | tail -1 | awk '{print $2}'`
        code_percent=`awk 'BEGIN { printf "%.1f%",('$code_num'/'$total_nums')*100 }'`
        #分别计算请求最多的状态码百分比
        echo ""
        echo -e "状态码为 ${code_name} 的共有 ${code_num} 条，占比:\033[31;49;1m ${code_percent} \033[31;49;0m \n"
        #分别计算每个最多状态码的最多ip
        echo -e "\033[32;49;1m*.*.*.*.\033[31;49;0m状态码为${code_name}访问最多的前${top_num}个ip: "
        grep "responseCode=${code_name}" $log_file | awk -F "sourceAddress=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -rn | head -${top_num}
    done
    echo ""
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
    simple)
        public
        simple
        ;;

    detail)
        public
        detail
        ;;

    help)
        echo ""
        echo -e "\033[44;36m1. 脚本使用方法: sh $0 { simple | detail | help }\033[0m"
        echo -e "\033[44;36m   simple选项代表错略分析; detail代表详细分析.\033[0m \n"
        echo -e "\033[44;36m2. 请确保日志必须为如下格式: \033[0m \n"
        log_format
        ;;

    *)
        echo ""
        echo -e $"Usage: $0 { simple | detail | help }\n"
esac
exit 0

