# Shell脚本 bad interpreter:No such file or directory & /bin/bash^M: bad interpreter错误解决方法

在 windows 下保存了一个脚本文件，用 ssh 上传到 centos，添加权限执行 nginx 提示没有那个文件或目录。  
shell脚本 放到`/etc/init.d/`目录下，再执行 /etc/init.d/nginx，提示多了这句`/bin/bash^M: bad interpreter`。
网上找了资料才知道  
如果这个脚本在 Windows 下编辑过，就有可能被转换成 Windows 下的`dos文本格式`了，这样的格式每一行的末尾都是以`\r\n`来标识，它的 ASCII码 分别是 0x0D，0x0A。如果你将这个脚本文件直接放到 Linux 上执行就会报`/bin/bash^M: bad interpreter`错误提示。  
解决方法很简单，首先你先要检查一下看看你的脚本文件是不是这个问题导致的，用 vi命令 打开要检查的脚本文件，然后用  
`:set ff?`  
命令检查一下，看看是不是 dos 字样，如果是 dos格式 的，继续执行  
`:set ff=unix`    
然后执行    
`:qw`    
保存退出即可。  