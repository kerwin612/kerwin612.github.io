# 在Ubuntu 12.04安装和设置SSH服务

1. 安装 Ubuntu缺省安装了openssh-client,所以在这里就不安装了，如果你的系统没有安装的话，再用apt-get安装上即可。 安装ssh-server `sudo apt-get install openssh-server` 安装ssh-client `sudo apt-get install openssh-client`
2. 确认sshserver是否安装好

   ```text
   ps -e | grep sshd
   450 ?        00:00:00 sshd
   ```

   如果看到sshd那说明ssh-server已经启动了。  
   如果只有ssh-agent说明ssh-server还没有启动，需要执行命令启动ssh服务：`/etc/init.d/ssh start`；  
   _注：_在ubuntu-12.04-server-i386.iso安装中只显示sshd这一项

3. 扩展配置 SSH默认服务端口为22，用户可以自已定义成其他端口，如222，需要修改的配置文件为：`/etc/ssh/sshd_config` 把里面的Port参数修改成222即可 然后重启SSH服务：`sudo/etc/init.d/ssh restart`

若安装openssh-server时提示下面错误：

```text
bill@ubuntu:~$ sudo apt-get install openssh-server
Reading package lists… Done
Building dependency tree
Reading state information… Done
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
openssh-server: Depends: openssh-client (= 1:5.3p1-3ubuntu3) but 1:5.3p1-3ubuntu7 is to be installed
E: Broken packages
```

则需卸载掉默认安装的openssh-client（因版本较新，而openssh-server依赖的版本较旧）：`sudo apt-get autoremove openssh-client`  
然后再重新安装它们：`sudo apt-get install openssh-client openssh-server`  
启动sshd服务：`sudo /etc/init.d/ssh start`  
这样，可以在远程Linux机器上利用 _scp_ 命令往我的ubuntu上copy文件了

