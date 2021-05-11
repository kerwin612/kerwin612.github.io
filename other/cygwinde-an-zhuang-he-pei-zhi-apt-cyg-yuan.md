# Cygwin的安装和配置apt-cyg源

`cygwin`能够在`windows`下模拟`Linux`下的命令行环境，能够应用`Linux`下的很多命令，很强大。

安装很简单，从[cygwin](http://www.cygwin.com/)下载`setup.exe`运行，然后设定镜像下载站点，就能自动从网上下载相关的程序的安装包。安装过程中会提示选择镜像下载点，我选择了以`.cn`结尾的中国镜像站点下载，但是发现一个问题，选择`http`的站点下载时，虽然速度很快，但是会莫名其妙的卡住，后来选择了`ftp`下载就好了。我用的是东北大学的`ftp`源`ftp://mirrors.neusoft.edu.cn/mirror/cygwin/`

安装`cygwin`时，默认没有`wget`程序。如果要安装程序，还要再次运行`setup`来寻找新的软件包安装，所以在安装时最好先选上`wget`程序。然后可以用`wget`下载`apt-cyg`的程序，以后就可以在`cygwin`下用`apt-cyg`安装程序了。

```bash
wget http://apt-cyg.googlecode.com/svn/trunk/apt-cyg -P /bin
chmod.exe +x /bin/apt-cyg
```

`apt-cyg`安装源为`ftp://mirror.mcs.anl.gov`，可以自定义更新源，网上都推荐用网易的`http://mirrors.163.com/cygwin/`，但是在`cygwin`的官方镜像中并没有网易的站点，怀疑网易的站点可能更新慢，就还是选择了安装`cygwin`时用的更新源`http://mirrors.neusoft.edu.cn/cygwin/`

```bash
apt-cyg -m http://mirrors.neusoft.edu.cn/cygwin/
```

然后更新一下源

```bash
apt-cyg update

Working directory is /setup
Mirror is http://mirrors.ustc.edu.cn/cygwin/
--2014-04-22 17:56:29--  http://mirrors.ustc.edu.cn/cygwin//x86_64/setup.bz2
Resolving mirrors.ustc.edu.cn (mirrors.ustc.edu.cn)... 202.141.176.110, 2001:da8:d800:95::110
Connecting to mirrors.ustc.edu.cn (mirrors.ustc.edu.cn)|202.141.176.110|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 344196 (336K) [text/plain]
Saving to: ‘setup.bz2’

100%[==========================================================================================>] 344,196     1.07MB/s   in 0.3s

2014-04-22 17:56:30 (1.07 MB/s) - ‘setup.bz2’ saved [344196/344196]

Updated setup.ini
```

显示以上信息说明源更新成功。

## 配置`cygwin`的环境

此外，虽然可以`cygwin`现在对中文的支持很好了，但是如果提示信息显示为中文，看着很别扭，只要能够显示`windows`下的中文文件名就可以了，提示信息还是显示为英文好。所以配置一下`cygwin`的语言环境。同时也更改一下`cygwin`的提示符式样和命令别名。编辑`/home/用户名/.bashrc`。在末尾添加

```bash
PS1="\[\e[1;37m\][\u@\h \[\e[1;34m\]\W\[\e[1;37m\]]\[\e[1;36;5m\]\\$\[\e[m\]"
export LC_ALL="en_US.UTF-8"
```

同时去掉文件中很多`alias`选项的注释记号，好了，现在是我喜欢的`Linux`命令行样式。

转：[https://github.com/chenui/win7/blob/master/cygwin.setup.apt-cyg.source.md](https://github.com/chenui/win7/blob/master/cygwin.setup.apt-cyg.source.md)

