# CentOS 7.x设置自定义开机启动,添加自定义系统服务

Centos 系统服务脚本目录：**/usr/lib/systemd/**

有***系统（system）***和***用户（user）***之分，  
如需要开机***没有登陆***情况下就能运行的程序，存在 *系统服务（system）* 里，即：**/lib/systemd/system/**   
反之，***用户登录***后才能运行的程序，存在 *用户（user）* 里  
服务以**.service**结尾。  

这边以nginx开机运行为例

1. 建立服务文件    

*vim /lib/systemd/system/nginx.service*  
```shell
[Unit]  
Description=nginx  
After=network.target  
   
[Service]  
Type=forking  
ExecStart=/www/lanmps/init.d/nginx start  
ExecReload=/www/lanmps/init.d/nginx restart  
ExecStop=/www/lanmps/init.d/nginx  stop  
PrivateTmp=true  
   
[Install]  
WantedBy=multi-user.target
```
**[Unit]:服务的说明**  
Description:描述服务  
After:描述服务类别  

**[Service]服务运行参数的设置**  
Type=forking是后台运行的形式  
ExecStart为服务的具体运行命令   
ExecReload为重启命令   
ExecStop为停止命令    
PrivateTmp=True表示给服务分配独立的临时空间   
***注意：[Service]的启动、重启、停止命令全部要求使用绝对路径***

**[Install]服务安装的相关设置，可设置为多用户**   

2. 保存目录     

以754的权限保存在目录：**/lib/systemd/system**   

3. 设置开机自启动   

`systemctl enable nginx.service`

**其他：**   
```shell
chkconfig VS systemctl对比表，以 apache / httpd 为例
任务					旧指令							新指令
使某服务自动启动		chkconfig --level 3 httpd on	systemctl enable httpd.service
使某服务不自动启动		chkconfig --level 3 httpd off	systemctl disable httpd.service
检查服务状态			service httpd status			systemctl status httpd.service （服务详细信息） systemctl is-active httpd.service （仅显示是否 Active)
显示所有已启动的服务	chkconfig --list				systemctl list-units --type=service
启动某服务			service httpd start				systemctl start httpd.service
停止某服务			service httpd stop				systemctl stop httpd.service
重启某服务			service httpd restart			systemctl restart httpd.service
```