#!/bin/bash

##check rabbitmq
##20170413
##V1.0


key1="error"
key2="unable"
key3="nodedown"
time=`date +%Y-%m-%d_%H:%M`
wechat="/usr/local/weihu/rabbitmq_check/wechat.sh"
host="蜂贷10.20.20.19"

key_check(){

/etc/init.d/rabbitmq-server status| grep -E "${key1}|${key2}|${key3}" >/dev/null 2>&1
ret=$?
if [ $ret -eq 0 ]
then
   ${wechat} 1 1 "告警等级：一级严重! \n\n ${host} rabbitmq 发生 ${key1} or ${key2} or ${key3} \n $time"
fi
}

python_check(){
a=`python /usr/local/weihu/rabbitmq_check/rabbitmq_check.py`
if [ $a -eq 0 ]
then 
   ${wechat} 1 1 "告警等级：一级严重! \n\n ${host} rabbitmq is down \n $time"
fi
}


key_check
python_check
