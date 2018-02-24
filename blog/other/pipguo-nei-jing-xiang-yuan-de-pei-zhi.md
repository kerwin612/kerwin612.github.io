#pip国内镜像源的配置  
>http://pypi.douban.com/ 豆瓣
http://pypi.hustunique.com/ 华中科技大学
http://pypi.sdutlinux.org/ 山东理工大学
http://pypi.mirrors.ustc.edu.cn/ 中国科学技术大学
http://mirrors.aliyun.com/pypi/simple/ 阿里云
https://pypi.tuna.tsinghua.edu.cn/simple/ 清华大学
  
1. 手动指定安装源 安装某个`python`模块  
```
pip -i http://pypi.douban.com/simple install dnspython
```   

2. 每次都手动指定安装源很麻烦，可以配置`pip`更新源  
```
#在当前用户主目录创建.pip文件夹
>cd ~
>mkdir .pip
```
```
#在.pip目录创建并编辑pip.conf
#pip安装需要使用的https加密，所以在此需要添加trusted-host 
[global]
trusted-host = mirrors.ustc.edu.cn
index-url = https://mirrors.ustc.edu.cn/pypi/web/simple
```  

3. 对于`window`系统修改配置文件在 `%HOMEPATH%\pip\pip.ini` ,基本配置与`linux`版的配置相同