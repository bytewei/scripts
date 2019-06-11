#!/bin/bash

tar_pkg=/tmp/redis-4.0.9.tar.gz
conf_file=/tmp/redis.conf
cluster_dir=/usr/local/redis-4.0.9/redis_cluster

if [ ! -f ${tar_pkg} ];then
    echo "没有找到文件：${tar_pkg}"
    exit 1
fi

if [ ! -f ${conf_file} ];then
    echo "没有找到文件：${conf_file}"
    exit 1
fi

ip=`ip a | grep -w 'inet' | grep -v '127.0.0.1' | awk '{print $2}'|cut -d/ -f1`

echo "安装依赖软件..."
yum install -y patch libyaml-devel autoconf patch readline-devel libffi-devel openssl-devel automake libtool bison sqlite-devel gcc gcc-c++ gcc-devel

echo "安装rvm..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
mkdir -p ~/.rvm/user
echo "ruby_url=https://cache.ruby-china.org/pub/ruby" > ~/.rvm/user/db
rvm -v
echo "安装ruby-2.4.2..."
rvm install 2.4.2
echo "安装redis-dump..."
gem install redis-dump -V

echo "解压缩redis包..."
cd /usr/local/
tar zxf ${tar_pkg}

echo "编译redis..."
cd /usr/local/redis-4.0.9
make
make install
\cp src/redis-trib.rb /usr/local/bin

echo "创建redis cluster目录..."
cd ${cluster_dir}/..
mkdir -p ${cluster_dir}/700{1,2,3,4,5,6}

echo "配置redis cluster文件..."
\cp -fv ${conf_file} ${cluster_dir}/7001/redis.conf
\cp -fv ${conf_file} ${cluster_dir}/7002/redis.conf
\cp -fv ${conf_file} ${cluster_dir}/7003/redis.conf
\cp -fv ${conf_file} ${cluster_dir}/7004/redis.conf
\cp -fv ${conf_file} ${cluster_dir}/7005/redis.conf
\cp -fv ${conf_file} ${cluster_dir}/7006/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7001/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7002/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7003/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7004/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7005/redis.conf
sed -i "s/listenip/${ip}/g" ${cluster_dir}/7006/redis.conf
sed -i 's/listenport/7001/g' ${cluster_dir}/7001/redis.conf
sed -i 's/listenport/7002/g' ${cluster_dir}/7002/redis.conf
sed -i 's/listenport/7003/g' ${cluster_dir}/7003/redis.conf
sed -i 's/listenport/7004/g' ${cluster_dir}/7004/redis.conf
sed -i 's/listenport/7005/g' ${cluster_dir}/7005/redis.conf
sed -i 's/listenport/7006/g' ${cluster_dir}/7006/redis.conf

echo "启动各redis实例..."
source /etc/profile
cd ${cluster_dir}
redis-server 7001/redis.conf
redis-server 7002/redis.conf
redis-server 7003/redis.conf
redis-server 7004/redis.conf
redis-server 7005/redis.conf
redis-server 7006/redis.conf

echo "创建redis cluster..."
cd ${cluster_dir}
echo "yes" | redis-trib.rb create --replicas 1 ${ip}:7001 ${ip}:7002 ${ip}:7003 ${ip}:7004 ${ip}:7005 ${ip}:7006

echo "测试redis cluster实例..."
redis-cli -h ${ip} -p 7001 ping
echo "查看redis cluster状态..."
redis-cli -h ${ip} -p 7001 -c cluster nodes

