在VirtualBox里安装CentOS 6操作系统，设置虚拟机的名称为CentOS-6.5。创建root密码和管理员用户（假设用户名为vbox）。

在虚拟机网络设置中，添加一个新的网络适配器，设置类型为Host-only。确保适配器1的类型为NAT，适配器2的类型为Host-only。

启动创建的虚拟机，使用root用户登录，安装开发工具：
```
#!bash
yum group install ‘Development Tools’
yum install kernel-devel
```
安装EPEL：
```
wget 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm'
yum localinstall epel-release-latest-6.noarch.rpm
yum makecache
```
在虚拟机管理界面选择安装Guest Additions，将在虚拟机中插入一张光盘。在虚拟机中使用
```
#!bash
mount /dev/cdrom /mnt
```
挂载光盘，然后进入到/mnt目录中，运行：
```
./VBoxLinuxAdditions.run
```
编辑/etc/sysconfig/network-scripts/ifcfg-eth0 （适配器1），加入以下内容：
```
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
```
编辑/etc/sysconfig/network-scripts/ifcfg-eth1 （适配器2），加入以下内容：
```
DEVICE=eth1
TYPE=Ethernet
UUID=51c7097b-ed49-47ed-a8fb-b3038f351df5
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.56.110
PREFIX=24
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth1"
```
编辑/etc/rc.local，加入以下内容（根据虚拟机的/Custom/IP和/Custom/Netmask自动设置适配器2的静态IP地址）：
```
#!bash
vboxproperty(){
  local val=`VBoxControl --nologo guestproperty get $1`
  if [ "$val" != "No value set!" ];then
  echo $val | awk '{print $2}'
  fi
}

IP=`vboxproperty /Custom/IP`
NETMASK=`vboxproperty /Custom/Netmask`
if [ -n "$IP" -a -n "$NETMASK" ];then
  ifconfig eth1 $IP netmask $NETMASK
fi
hostname `vboxproperty /Custom/HostName`
```
禁用防火墙：
```
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
service iptables save
```
重启虚拟机：
```
reboot
```
将本地的SSH key添加到虚拟机中：
```
ssh-copy-id vbox@192.168.56.110
```
通过```ssh vbox@192.168.56.110```登录虚拟机，安装Grid Engine相关的软件
```
sudo yum install gridengine gridengine-qmaster gridengine-execd gridengine-qmaster gridengine-qmon
```
下载最新版的[Java Linux 64位版本](https://www.java.com/en/download/manual.jsp)，然后安装：
```
sudo yum localinstall jre-8u121-linux-x64.rpm
```

Grid Engine的程序被安装到/usr/share/gridengine下，同时会创建用户sgeadmin:sgeadmin。

之后关闭虚拟机。

在本地的一个目录通过git下载脚本：
```
git clone https://ltbyshi@bitbucket.org/ltbyshi/vboxcluster.git
```
编辑GenVMInfo.sh，设置需要生成的虚拟机的个数（默认为4个），域名（默认为vm$i.centos6.vbox)及IP地址（默认为192.168.56.111-)。然后运行：
```
./GenVMInfo.sh
```
生成一个名为vms.txt的文件：
```
centos6-vm1	vm1.centos6.vbox	192.168.56.111	255.255.255.0
centos6-vm2	vm2.centos6.vbox	192.168.56.112	255.255.255.0
centos6-vm3	vm3.centos6.vbox	192.168.56.113	255.255.255.0
centos6-vm4	vm4.centos6.vbox	192.168.56.114	255.255.255.0
```
为了方便登录，可以通过```./GenHosts.sh``` 命令生成一个hosts文件：
```
# VBox cluster
192.168.56.111	vm1.centos6.vbox
192.168.56.112	vm2.centos6.vbox
192.168.56.113	vm3.centos6.vbox
192.168.56.114	vm4.centos6.vbox
```
把hosts文件中的内容添加到虚拟机的/etc/hosts中。也可以把hosts的内容添加到系统的/etc/hosts中。

编辑CreateVMs.sh，在以下一行修改刚才创建的虚拟机的名字（默认为CentOS-6.5）
```
VBoxManage clonevm "CentOS-6.5" --snapshot "Origin" --options link --name "$vm" --register
```
之后运行 ```./CreateVMs.sh```，将克隆（增量克隆）刚才创建的虚拟机为4个虚拟机，名称为vms.txt文件的第一列。

启动所有的虚拟机：```./StartVMs.sh```。

如果需要关闭所有虚拟机的话，可以运行：```./HaltVMs.sh```

如果需要删除整个集群，可以运行：```./DeleteVMx.sh```

如果需要在所有虚拟机上运行某个命令，可以运行：```./VMExec.sh command [arguments] ...```

如果需要根据vms.txt的内容更新IP地址，可以运行：```./SetIP.sh```

等待全部启动后，假设vm1为管理节点，vm1-4为计算节点。先通过```ssh vbox@vm1```登录vm1。

进入/usr/share/gridengine，运行：```./install_qmaster```。大部分问题都可选择默认。安装完后，如果sgemaster不能成功启动，可以运行```service sgemaster start```手动启动qmaster。通过以下命令把sgemaster加入到开机启动脚本：
```
chkconfig sgemaster on
```
之后可以用qhost命令测试一下能否与sgemaster成功通信：
```
HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
-------------------------------------------------------------------------------
global                  -               -     -       -       -       -       -
```
接下来安装计算节点后台程序sge_execd，运行```./inst_sge -x```，按照提示安装计算节点和设置队列。安装完之后运行qhost命令可以看到已经有一个计算节点：
```
HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
-------------------------------------------------------------------------------
global                  -               -     -       -       -       -       -
centos6                 lx26-amd64      2  0.00  996.3M  182.0M     0.0     0.0
```
添加vbox用户到管理员：
```qconf -am vbox```
添加节点列表：
```qconf -ahgrp @allhosts```
在编辑器里加入计算节点：
```
group_name @allhosts
hostlist centos6.vbox
```
添加队列：
```qconf -aq all.q```
编辑以下几行：
```
hostlist @allhosts
```
添加提交任务节点：
```
qconf -as centos6.vbox
```
用```qstat -g c```查看队列状态：
```
CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE
--------------------------------------------------------------------------------
all.q                             0.00      0      0      2      2      0      0
```
测试提交任务：
```
qlogin
```
测试提交任务：
```
echo date | qsub
```


参考链接：

* http://idolinux.blogspot.com/2008/09/deploying-sun-grid-engine-on-cluster.html
