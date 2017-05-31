默认情况下 mysql更改端口后是不能通过`SELinux`的

提示启动错误，那么首先就要看mysql的错误日志

可是我不知道mysql错误日志的位置

首先，更改`SELinux`的模式为`permissive` 然后启动mysql(`permissive`模式下是能够启动mysql的)
```bash
setenforce 0
```
然后是用`ps`命令查看日志位置：
```bash
ps ax|grep mysql
或者
ps ax|grep "[m]ysql"
```
从输出中找到`--log-error`

然后打开错误日志

提示：
```bash
[ERROR] Can't start server: Bind on TCP/IP port: Permission denied
150210 19:57:52 [ERROR] Do you already have another mysqld server running on port: 3308 ？
```
明显是绑定到3308端口的时候提示错误了！

那么就要更改`SELinux`对mysql开启3308端口

网上搜索后说是需要使用`semanage`

但是centos里面并没有找到`semanage`命令

那么查看哪个包提供了`semanage`
```bash
yum provides /usr/sbin/semanage
```
发现是`policycoreutils-python`包

于是安装`policycoreutils-python`包
```bash
yum install policycoreutils-python
```
安装完成后，为mysql绑定3308端口
```bash
semanage port -a -t mysqld_port_t -p tcp 3308
```
然后设置`SELinux`为强制模式然后重启mysql就可以了
```bash
setenfoce 1
service mysql restart
```

转自：[http://m.www.cnblogs.com/waitfate/p/4285859.html](http://m.www.cnblogs.com/waitfate/p/4285859.html)