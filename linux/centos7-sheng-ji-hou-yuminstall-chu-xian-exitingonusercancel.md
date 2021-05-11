# centos 7 升级后yum install出现Exiting on user cancel

centos 7.x升级后用yum install进行安装时经常出现`Exiting on user cancel`，例如：

```bash
[root@localhost ~]# yum install logstash
Loaded plugins: axelget, fastestmirror
No metadata available for base
No metadata available for docker-main-repo
No metadata available for epel
No metadata available for extras
No metadata available for logstash-1.5
No metadata available for updates
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: mirrors.ustc.edu.cn
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Resolving Dependencies
--> Running transaction check
---> Package logstash.noarch 1:1.5.6-1 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=========================================================================================================================================================================================================
 Package                                        Arch                                         Version                                            Repository                                          Size
=========================================================================================================================================================================================================
Installing:
 logstash                                       noarch                                       1:1.5.6-1                                          logstash-1.5                                        86 M

Transaction Summary
=========================================================================================================================================================================================================
Install  1 Package

Total download size: 86 M
Installed size: 133 M
Is this ok [y/d/N]: y
Downloading packages:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
logstash-1.5.6-1.noarch.rpm                                                                                                                                                       |    0 B  00:00:30 ... 
logstash-1.5.6-1.noarch.rpm                                                            2% [==                                                                          ] 141 kB/s | 2.5 MB  00:10:09 ETA 

Exiting on user cancel
```

总是出现`Exiting on user cancel`，导致不能正常安装。

这是yum的一个bug导致的问题。修改`/usr/lib/python2.7/site-packages/urlgrabber/grabber.py`.

`vi /usr/lib/python2.7/site-packages/urlgrabber/grabber.py`  
将第1510行和1517行注释掉即可  
修改前：

```python
1510             elif errcode == 42:
1511                 # this is probably wrong but ultimately this is what happens
1512                 # we have a legit http code and a pycurl 'writer failed' code
1513                 # which almost always means something aborted it from outside
1514                 # since we cannot know what it is -I'm banking on it being
1515                 # a ctrl-c. XXXX - if there's a way of going back two raises to
1516                 # figure out what aborted the pycurl process FIXME
1517                 raise KeyboardInterrupt
```

修改后：

```python
1510             #elif errcode == 42:
1511                 # this is probably wrong but ultimately this is what happens
1512                 # we have a legit http code and a pycurl 'writer failed' code
1513                 # which almost always means something aborted it from outside
1514                 # since we cannot know what it is -I'm banking on it being
1515                 # a ctrl-c. XXXX - if there's a way of going back two raises to
1516                 # figure out what aborted the pycurl process FIXME
1517             #    raise KeyboardInterrupt
```

然后以root用户运行如下命令升级：

```bash
yum clean metadata
yum clean all
yum upgrade
```

升级完成后运行yum命令安装即可。

参考文档：[http://www.ostechnix.com/yum-dont-work-in-clean-centos-7-how-to-fix-it/](http://www.ostechnix.com/yum-dont-work-in-clean-centos-7-how-to-fix-it/)

