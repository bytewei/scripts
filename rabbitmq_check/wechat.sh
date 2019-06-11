#!/bin/bash

CropID='wxb28d816e6f9da986'  
Secret='IRAXf0Qn9S7eN4RkakmFfcegARVHto554lV-LoKgluM'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
function body() {
        local int AppID=2      
        local UserID=@all
        local Msg=$(echo "$@" | cut -d" " -f3-)
        printf '{\n'
        printf '\t"touser": "'"$UserID"\"",\n"
        printf '\t"msgtype": "text",\n'
        printf '\t"agentid": "'"$AppID"\"",\n"
        printf '\t"text": {\n'
        printf '\t\t"content": "'"$Msg"\""\n"
        printf '\t},\n'
        printf '\t"safe":"0"\n'
        printf '}\n'
}
        /usr/bin/curl --data-ascii "$(body $1 $2 $3)" $PURL

