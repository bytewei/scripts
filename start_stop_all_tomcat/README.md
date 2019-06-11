# 一键启停多个tomcat

## 说明

本脚本用于一键启动、关闭单台服务器上多个tomcat服务。<br>

首先列出单台服务器上运行的多台tomcat清单（service.txt），并将该清单放在目标目录下（/home/tomcat-path/.tomcat_service.txt）。<br>

通过start_all_tomcat.sh脚本一键开启所有tomcat，通过stop_all_tomcat.sh一键停止所有tomcat。<br>

tomcat要通过普通账户启动，但执行一键启、停脚本的账户可以为root或者该普通账户。<br>

