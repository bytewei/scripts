#!/bin/bash

# 定义最终挂载的名称
partition=/data
# 定义逻辑卷组的名称
vgname=data01
# 定义逻辑卷的名称
lvmname=lvm-data
# 要分区的磁盘
disk='/dev/sdb'

uname -r|grep "3.10"
if [ $? -ne 0 ];then
    echo "操作系统不是centos7. 该脚本针对centos7的操作系统"
    exit 1
fi

yum install -y lvm2

# 自动化分区
fdisk $disk << EOF
n
p
1


t
8e
w
EOF

pvcreate ${disk}1
vgcreate $vgname ${disk}1
lvcreate -l 100%VG -n $lvmname $vgname

mkfs.xfs /dev/$vgname/$lvmname

mkdir -p $partition
echo "/dev/$vgname/$lvmname  $partition  xfs defaults  0 0" >> /etc/fstab

mount -a
df -h

