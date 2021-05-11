# 配置CENTOS YUM更新源

众所周知，Centos 有个很方便的软件安装工具 yum，但是默认安装完centos，系统里使用的是国外的centos更新源，这就造成了我们使用默认更新源安装或者更新软件时速度很慢的问题。

为了使用yum工具能快速的安装更新软件，我们需要将默认的yum更新源配置为国内的更新源。yum更新源配置文件位于centos目录 /etc/yum.repos.d/ 下。

首先提供几个国内快速的更新源：

**教育网资源：**

```text
1 上海交大： http://ftp.sjtu.edu.cn/centos/
服务器位于北京，中国教育网网络中心，下载速度高达十M。
北方用户与教育网用户推荐，速度飞快。
需要手动创建 CentOS-Base.repo文件。

2 中国科技大学：http://centos.ustc.edu.cn
服务器位于合肥。 南方用户推荐。 同样的，CenOS版本非常丰富，适合长期使用。
```

**非教育网资源：**

```text
1 sohu的开源镜像服务器：http://mirrors.sohu.com/
服务器位于山东省联通

2 网易的开源服务器镜像： http://mirrors.163.com/centos
速度也不错，全国用户推荐

3 度娘？   怎么没有度娘的开源镜像。度娘每年坑骗这么多血汗钱，难道连个开源也供不起么？ 百分鄙视！
```

总之，大家在使用前可以 ping 一下一上更新源，看哪个快就用哪个。

**CentOS-Base.repo** 文件示例，这个文件在这个目录下 _**/etc/yum.repos.d/**_

```text
[base]
name=CentOS-$releasever - Base 
baseurl=http://mirrors.163.com/centos/6.4/os/$basearch/ 
gpgcheck=1 
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6   

[updates]
name=CentOS-$releasever - Updates 
baseurl=http://mirrors.163.com/centos/6.4/updates/$basearch/ 
gpgcheck=1 
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6 

[addons] 
name=CentOS-$releasever - Addons 
baseurl=http://mirrors.163.com/centos/$releasever/addons/$basearch/ 
gpgcheck=1 
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6 

[extras] 
name=CentOS-$releasever - Extras 
baseurl=http://mirrors.163.com/centos/6.4/extras/$basearch/ 
gpgcheck=1 
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6 

[centosplus] 
name=CentOS-$releasever - Plus 
baseurl=http://mirrors.163.com/centos/6.4/centosplus/$basearch/ 
gpgcheck=1 
enabled=0 
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6
```

从以上配置文件可以看出，需要根据各家源情况 有选择的配置 \[base\] \[updates\] \[addons\] \[extras\] \[centosplus\] 这几项。

每一项只要修改baseurl 和gpgkey 为相应源地址即可。

以上配置结束之后，要清空yum 缓存，并重建yum缓存，执行以下命令：  
`yum clean all && yum clean metadata && yum clean dbcache && yum makecache && yum update`

