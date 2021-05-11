# 使用命令行启动VirtualBox虚拟机

装上 VirtualBox 就琢磨着如何让它开机自动启动，又或者能够通过命令行的形式直接启动指定的虚拟机。看了下 VirtualBox 的官方文档，发现有一个命令可以满足我的需求，即 VBoxManage 。 VBoxManage 提供了一系列的虚拟机管理命令，包括创建/删除/启动/修改等等，这里不一一列举。有点像 Xen 的 XM 命令。不过这里只关心启动虚拟机的命令： VBoxManage startvm 。 VBoxManage 的完整命令列表可以参考这里。

VBoxManage startvm 子命令可以开启一台状态为关闭或者保存的虚拟机。该命令的语法为:  
`VBoxManage startvm uuid>|name... [--type gui|sdl|headless]`

可以通过虚拟机的 uuid 或者 name 来指定某台虚拟机，可以通过另外一个子命令 list 列出系统已有的虚拟机：

```text
$ VBoxManage list vms
"XP" {8842d793-228c-458e-a880-8051193fd2db}
```

我系统上已经安装了一台名为 XP 的虚拟机，后面括号内部的是它的 UUID 。

VBoxManage startvm 子命令可以通过 –type 参数指定启动的方式，其中 gui 就是图形化界面，这和我们平时启动的方式一样。 sdl 也是图形化界面，但是少掉了部分功能，比如没有菜单等，一般用于调试过程。最后 headless 是在后台运行，并且默认开启 vrdp 服务，可以通过远程桌面工具来访问。关于这三种启动方式的介绍可以看手册中的这一篇。所以一般我们使用 gui 或者 headless 类型启动。

使用gui类型启动虚拟机：

```text
$ VBoxManage startvm XP --type gui
```

执行结束后，就会启动指定的虚拟机，几乎和平时没什么区别。

使用 headless 类型启动虚拟机:  
`$ VBoxManage startvm "XP" --type headless`  
或者  
`$ VBoxHeadless --startvm "XP"`

结果返回：

```text
$ rdesktop -a 16 -N -g 1280x800 127.0.0.1:3389
Autoselected keyboard map en-us
ERROR: connect: Connection refused
```

翻了下手册，结果发现要获得 VRDP 的支持还需要安装额外的扩展包，详细说明可以参考这里。从 VirtualBox 的下载页面选择相应的版本下载扩展包。下载完成后，双击即可以完成安装，或者在菜单中 File-Preference-Extensions 可以安装和查看已安装的扩展包。

安装好再次执行上面的远程命令，这下可以看见虚拟机界面了吧。可以通过 ctrl+alt+enter 切换全屏。不过我这里用 rdesktop 全屏后，屏幕就黑了，只有点过的地方才会恢复。不知道是什么原因，我就干脆用 TigerVNC 了，同时在启动 headless 的时候加上 -n 参数 `{$ VBoxHeadless -n -s winxp (VBoxHeadless -s winxp --vnc --vncport 5900 --vncpass password)}` ，通过以下命令远程连接:  
`$ vncviewer localhost:5900`

按下 F8 会出现一个菜单，里面可以切换全屏。

一切相关的命令：

|  |  |
| :--- | :--- |
| VBoxManage list runningvms | 列出运行中的虚拟机 |
| VBoxManage controlvm XP acpipowerbutton | 关闭虚拟机，等价于点击系统关闭按钮，正常关机 |
| VBoxManage controlvm XP poweroff | 关闭虚拟机，等价于直接关闭电源，非正常关机 |
| VBoxManage controlvm XP pause | 暂停虚拟机的运行 |
| VBoxManage controlvm XP resume | 恢复暂停的虚拟机 |
| VBoxManage controlvm XP savestate | 保存当前虚拟机的运行状态 |

