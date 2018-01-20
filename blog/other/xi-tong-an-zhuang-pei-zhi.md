###系统环境准备：

	* 系统下载：https://downloads.raspberrypi.org/raspbian\_lite\_latest 	\[2017-11-29\]
	* 系统烧录工具下载：https://sourceforge.net/projects/win32diskimager/files/Archive/
	* 将下载好的系统，解压到任意磁盘根目录（最终系统镜像文件【.img】路径不能包含中文名）
	* 将内存卡插到读卡器，将读卡器插到电脑上，
	* 解压烧录工具，运行，在弹出的软件窗口，选择刚刚解压好的【.img】系统文件，
	* 在软件【Device】项选择读卡器所在的盘符，
	* 点击【Write】，成功之后会弹出是否格式化盘符，，千万别点格式化，直接关掉，会看到一个Write Success的弹框，也可以关掉。
	* 这个时候去【我的电脑】里面看，内存卡变成了两个磁盘，其中一个【boot】磁盘是可以访问的。先不要拔掉读卡器，接着开始下一步。	

###无屏幕和键盘配置树莓派WIFI和SSH：

	* 点击【boot】盘符，
	* 在根目录，新建一个文件，名称为【ssh】，不能包含任何后缀。
	* 再新建一个文件，名称为【wpa_supplicant.conf】，然后打开这个文件（任意文本编辑器打开就可以），编辑内容  
	
```
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
  ssid="WiFi-A"
  psk="12345678"
  key_mgmt=WPA-PSK
  priority=1
}
```
	* 把上面内容复制到文件里就可以了，然后【ssid】项的值(WiFi-A)改为你家WIFI名称，【psk】项的值(12345678)改为你家WIFI密码，
	* 大功告成，这个时候你可以拔出读卡器，然后把内存卡插到树莓派，通电开机，，，这个时候你上你家路由器的管理APP应该可以看到树莓派已经成功接入你家网络。记下树莓派的IP地址。

