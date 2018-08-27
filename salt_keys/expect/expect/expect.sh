#!/bin/bash
##功能：入口（执行）脚本
##任小为 2017.07.20
##版本：v1.0

##定位脚本所在当前目录
dir=$(cd "$(dirname "$0")"; pwd)

host_file="$dir/conf/passwd.txt"
check_ip="$dir/conf/check_ip.sh"
expect_shell="$dir/scripts/expect.exp"

install_expect(){
    expect -v > /dev/null 2>&1
    if [ ! $? = 0 ];then
        yum install -y expect
    fi
}

expect_func(){
    for i in `awk '{print $1}' $host_file`;do  
        j=`awk -v I="$i" '{if(I==$1)print $2}' $host_file`  
        k=`awk -v I="$i" '{if(I==$1)print $3}' $host_file`  
        m=`awk -v I="$i" '{if(I==$1)print $4}' $host_file`  

        expect $expect_shell $i $j $k $m 
    done  
}

echo ""
echo -e "执行脚本前，请编辑服务器文件：conf/passwd.txt \n"
echo -e "脚本执行成功后，请在本机（salt-master）上执行“salt-key -A” 以注册相应服务器 \n"
echo -e "为了方便查看操作结果，请把日志打出，建议执行: $0 | tee /tmp/expect_log.txt \n"
echo -e " [1] 检查IP是否能ping通\n"
echo -e " [2] 一键部署\n"

read -p "请选择序号：" num
echo ""

case "$num" in
    [1])
        sh $check_ip
        ;;
    [2])
        install_expect
        expect_func
        ;;
     *)
        echo -e "请正确选择序号：1 | 2 ，建议执行: $0 | tee /tmp/expect_log.txt \n"
        ;;
esac

