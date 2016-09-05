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
4. 注册服务，运行regedit 在注册表中，定位到 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VM_AutoStart` 新建项： `Parameters` 在 *Parameters* 项里面，新建字符串 `Application` ，字符串的值： `"E:\VMwareWorkstation\vmware.exe" -x "D:\vmare\windows2003\windows server2003.vmx"` (如果你想要开机加载两个虚拟机系统，只需要在其后再添加一个虚拟机配置文件路径即可） 
5. 设置虚拟机启动状态，管理工具－服务，选择 VM_AutoStart 的属性－登录，选中“本地系统帐户”，并勾选“允许服务与桌面交互”，这样，你的电脑开机后就会出现 vmware 的启动界面了。
6. 重启电脑试试！（注意：重启电脑时vmware会自动运行，但第一次运行你要把每次都弹出“提示”等前面的的选框钩去掉，去掉之后按下power off按扭，重新启动电脑，vmware就会保存你的设置，这样免得vmware每次都弹出这些对话框而卡在哪里。没有按poweroff按扭重启电脑vmware是不会保存你的设置的！）  
7. 删除服务，停止vwware的服务：`net stop vmwareautorun`，删除服务：`D:\tools\instsrv.exe VM_AutoStart remove`  


###一条批处理命令启动VMware虚拟机  
我的工作机是 Window7 系统，每天都要跟服务器版的 Ubuntu 系统打交道，于是用 VMware 搭建了 Ubuntu 的环境，上班第一件事是双击桌面上的 VMware 图标，然后选择 Ubuntu 虚拟机，点击启动按钮，由于我在 Ubuntu 系统上都是用 shell 命令操作，所以根本用不到图形界面，虚拟机开机后我要切换为后台模式运行 (Run in Background) 。上述操作费时费力，根据机器延时还有不同程度的等待，体验欠佳，于是我上网找到了一种一键可以开启 VMware 下某个虚拟机的方法，分享给大家。首先说一下我的 VMware 是7.1.4版本(64位)，无论32位还是64位的 VMware 都自带一个命令行的工具： VMRun ，可以通过给它一定的参数实现指定虚拟系统的启动。我的 VMware 软件安装路径是：`C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe`， Ubuntu 虚拟机的存放路径是： `D:\Ubuntu\Ubuntu.vmx` 很简单，只需要下面一行命令就可以启动 Ubuntu 虚拟机 `"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\Ubuntu\Ubuntu.vmx"` 新建个文本文件，复制上面这行命令保存为 start.bat (批处理文件类型)，然后双击这个文件就能启动 Ubuntu 虚拟机。上面这行命令的格式是： vmrun的路径 start 虚拟机存放路径如果仅仅这样做，虚拟机启动时还是会显示界面，如何让虚拟机在后台运行呢？只需在上述命令后添加一个参数 nogui 例如： `"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\Ubuntu\Ubuntu.vmx" nogui` 这样虚拟机就会默默在后台启动，使用时直接用终端工具 putty 登陆 Ubuntu 系统即可。如果希望让虚拟机在 windows 启动后自动开启，可以将上述批处理文件加入 windows 的启动项中，或是计划任务里。此外，通过为 vmrun.exe 传递不同的参数可以实现不同的功能，如关闭虚拟机系统、运行程序等。直接运行 vmrun 程序，不带参数，即可查看其帮助文档。  





 
