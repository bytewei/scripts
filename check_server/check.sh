#!/bin/bash
# 功能：一键检测宿主机、虚拟机是否存活
# 作者：任小为
# 版本：v1.0

file=server.txt
result_base=/tmp/check_host_net

rm -rf $result_base
mkdir -p $result_base

super_host(){
    super_ip_list=${result_base}/super_ip_list.txt
    super_alive=${result_base}/super_alive.txt
    super_die=${result_base}/super_die.txt
    super_telnet=${result_base}/super_telnet.txt

    echo ""
    echo -e "\033[44;36m检测宿主机是否存活... \033[0m"

    egrep -v "#|^$" $file | awk '{print $1,$2}' | uniq > $super_ip_list

    count=0
    for ip in $(cat ${super_ip_list} | awk '{print $1}');do
        let count++
        echo "count=$count"

        ping -c 2 -i 0.02 $ip > /dev/null 2>&1
        if [ $? -eq 0 ];then
            echo $ip >> ${super_alive}
        else
            super_port=`grep $ip ${super_ip_list} | awk '{print $2}'`
            (sleep 1;) | telnet $ip ${super_port} >> ${super_telnet}
        fi
    done

    if [ -e ${super_telnet} ];then
        super_ip=${result_base}/super_ip.txt
        cat ${super_ip_list} | awk '{print $1}' > ${super_ip}

        cat ${super_telnet} | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4 >> ${super_alive}
        cat ${super_ip} ${super_alive} | sort | uniq -u > ${super_die}
    fi

    echo ""
    echo -e "\033[32;49;1m存活的宿主机: \033[31;49;0m"
    echo -e "`cat ${super_alive}`\n"
    
    if [ -s ${super_die} ];then
        echo -e "\033[31;49;1m检测不通的宿主机:\033[31;49;0m"
        echo -e "\033[31;49;1m`cat ${super_die}`\033[31;49;0m\n"
    else
        echo -e "\033[44;36m所有宿主机都存活.\033[0m\n"
    fi
}

sub_host(){
    sub_ip_list=${result_base}/sub_ip_list.txt
    sub_alive=${result_base}/sub_alive.txt
    sub_die=${result_base}/sub_die.txt
    sub_telnet=${result_base}/sub_telnet.txt

    echo ""
    echo -e "\033[44;36m检测虚拟机是否存活... \033[0m"

    egrep -v "#|^$" $file | awk '{print $3,$4}' | uniq > $sub_ip_list

    sub_count=0
    for sub_ip in $(cat ${sub_ip_list} | awk '{print $1}');do
        let sub_count++
        echo "count=${sub_count}"

        ping -c 2 -i 0.02 ${sub_ip} > /dev/null 2>&1
        if [ $? -eq 0 ];then
            echo ${sub_ip} >> ${sub_alive}
        else
            sub_port=`grep ${sub_ip} ${sub_ip_list} | awk '{print $2}'`
            (sleep 1;) | telnet ${sub_ip} ${sub_port} >> ${sub_telnet}
        fi
    done

    if [ -e ${sub_telnet} ];then
        sub_ip=${result_base}/sub_ip.txt
        cat ${sub_ip_list} |awk '{print $1}' > ${sub_ip}

        cat ${sub_telnet} | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4 >> ${sub_alive}
        cat ${sub_ip} ${sub_alive} | sort | uniq -u > ${sub_die}
    fi

    echo ""
    echo -e "\033[32;49;1m存活的虚拟机: \033[31;49;0m"
    echo -e "`cat ${sub_alive}`\n"

    if [ -s ${sub_die} ];then
        echo -e "\033[31;49;1m检测不通的虚拟机:\033[31;49;0m"
        echo -e "\033[31;49;1m`cat ${sub_die}`\033[31;49;0m\n"
    else
        echo -e "\033[44;36m所有虚拟机都存活.\033[0m\n"
    fi
}

case $1 in
    super)
        super_host
        ;;
    vm)
        sub_host
        ;;
    help)
        echo ""
        echo "`grep "功能" $file`"
        echo "super选项代表检测宿主机;"
        echo -e "vm选项代表检测虚拟机.\n"
        ;;
    *)
        echo ""
        echo -e $"Usage: sh $0 { super | vm | help }\n"
esac
exit 0 

