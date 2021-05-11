# VirtualBox绿色版的桥接网卡驱动安装

> 未指定要bridged的网络界面

原因分析：因为是绿色版本，所以没有装桥接的网卡驱动，要自己手动去安装。

解决办法：

打开 “本地连接” 的属性界面

选择 “Microsoft 网络客户端”，再点击下面的 “安装” 按钮

弹出 “选择网络功能类型” 的窗口，选择“服务”，点击下面的 “添加” 按钮

弹出 “选择网络服务” 的窗口，点击下面的 “从磁盘安装” 按钮

弹出浏览目录的界面，这里就选择你的 桥接的网驱动 所在的目录地址，我的桥接网卡驱动的目录路径为：

`F:\VirtualBoxPortable\App\VirtualBox\drivers\network\netflt\VBoxNetFltM.inf`

选择好后，点击 确认，就会自己安装桥接网卡驱动了

安装后，你就会发现在本地连接的属性界面， 有个 “VirtualBox Bridged Networking Driver” 的选项，那就代表我们安装的桥接网卡驱动，然后你再到虚拟机的网络设置里设置桥接，就不会有：~~**未指定要bridged的网络界面**~~ 的提示了。

## \#\#\#\#\#\#\#\#华丽的分割线

注意：有的人可能会选错了桥接网卡驱动，比如选择了`VBoxNetFlt.inf`，我开始也是选择了这个，结果虽然一样可以设置为桥接 的联网方式，不会有“**未指定要bridged的网络界面**” ，但是却导致虚拟机系统不能启动，报错：

> Cannot access the kernel driver！ Make sure the kernel module has been loaded successfully

