# VMWare 随系统启动指定虚拟机

做一名网络管理人员，VMware大家是必须要会用的，但在实际工作中，我们可能会在服务器是安装VMware，启用多个系统，但当服务器重启或其它非人为的，当网络管理员不在的情况下，VMware是不随系统而启动的，这样是非常麻烦的，如何让VMware随系统而启动并引导虚拟机操作系统呢！不可避免，企业的服务器不会象我们预想的那样一年365天不间断的运行。可能公司突然停电，或者服务器突然无故重启，这些情况都会造成电脑内的虚拟机开机不再运行。而如果此时系统管理员正好离开，那这个后果也就不言而喻了。所以，实现虚拟机开机自动启动，可以说是实现公司服务器正常运行的一个不可或缺的环节。实现其开机自动启动步骤其实很简单。这里用到的是微软的两个小工具。 **instsrv.exe** 和 **srvany.exe**   
微软对 *instsrv.exe* 的官方说明如下：  
  >Installsand uninstalls executable services and assigns names to them. 也就是个加载services的小东东。  
其用法如下： 
  `instsrv <service name> <srvany path>`（这里的 *srvany path* 也就是工具 *srvany.exe* 的路径了）  
  
解释下， *srvany.exe* 是微软出的用于将一个程序注册为一个服务的小程序。它可以实现讲任何程序设置成服务启动。  
1. 值得注意的是，将这两个文件下载下来后，将这两个文件放到D盘或其它地方如 D:\tools 
2. 了解 vmware.exe 的安装路径，以本机为例：E:\VMwareWorkstation\vmware.exe 。要启动的虚拟机配置文件路径，我的2003虚拟机的配置文件 windows2003.vmx 的路径是 D:\vmare\windows2003\windows server 2003.vmx 
3. 新建服务，假设服务名为 vmautostart ，打开运行，进入cmd字符，cd进入我们刚才放那两个文件夹 D:\tools ，键入命令行是：instsrv VM_AutoStart D:\tools\srvany.exe 
4. 注册服务，运行regedit 在注册表中，定位到 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VM_AutoStart` 新建项： `Parameters` 在*Parameters*项里面，新建字符串 `Application` ，字符串的值： "E:\VMwareWorkstation\vmware.exe" -x "D:\vmare\windows2003\windows server2003.vmx" (如果你想要开机加载两个虚拟机系统，只需要在其后再添加一个虚拟机配置文件路径即可） 
5. 设置虚拟机启动状态，管理工具－服务，选择 VM_AutoStart 的属性－登录，选中“本地系统帐户”，并勾选“允许服务与桌面交互”，这样，你的电脑开机后就会出现 vmware 的启动界面了。
6. 重启电脑试试！（注意：重启电脑时vmware会自动运行，但第一次运行你要把每次都弹出“提示”等前面的的选框钩去掉，去掉之后按下power off按扭，重新启动电脑，vmware就会保存你的设置，这样免得vmware每次都弹出这些对话框而卡在哪里。没有按poweroff按扭重启电脑vmware是不会保存你的设置的！）  
7. 删除服务，停止vwware的服务：`net stop vmwareautorun`，删除服务：`D:\tools\instsrv.exe VM_AutoStart remove`  




 
