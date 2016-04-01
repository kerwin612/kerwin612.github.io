#Linux下 RabbitMQ的安装与配置 
##Erlang安装
1. RabbitMQ是基于Erlang的，所以首先必须配置Erlang环境.
2. 从Erlang的[官网](http://www.erlang.org/download.html) 下载最新的erlang安装包.
3. 然后解压下载的gz包  tar zxcf  *.tar.gz
4. cd 进入解压出来的文件夹
5. 执行./configure --prefix=/opt/erlang  就会开始编译安装  会编译到 /opt/erlang 下 然后执行
6. make 和 make install
7. 编译完成以后，进入/opt/erlang，输入erl测试erlang是否安装成功。
8. 修改/etc/profile文件，增加下面的环境变量：
9. #set erlang environment
10. export PATH=$PATH:/opt/erlang/bin
11. source profile使得文件生效
12. 肯能会出现找不到包的情况，就直接yum install 吧！ 

*Ubuntu下安装出现`configure: error: No curses library functions found`解决：`apt-cache search ncurses``apt-get install libncurses5-dev`*

##二 simplejson安装
1. wget http://pypi.python.org/packages/source/s/simplejson/simplejson-下载simplejson
2. tar -zxvf simplejson-2.4.0.tar.gz解压缩文件
3. cd simplejson-2.4.0，python setup.py install。这是由于simplejson是依赖python脚本的

##三 RabbitMQ安装配置
1. rabbitmq的安装有很多版本，我们使用Generic Unix版本。
2. cd /
3. wget http://www.rabbitmq.com/releases/rabbitmq-server/v2.7.1/rabbitmq-server-generic-unix-2.7.1.tar.gz下载rabbitmq
4. tar zxvf rabbitmq-server-generic-unix-2.7.1.tar.gz -C /opt解压到指定的文件夹下
5. cd /opt，建立软链接ln -s rabbitmq-server-generic-unix rabbitmq
6. cd rabbitmq/sbin，./rabbitmq-server -detached可以实现后台启动
7. 修改/etc/profile，添加环境变量
8. #set rabbitmq environment
9. export PATH=$PATH:/opt/rabbitmq/sbin
10. source profile使得文件生效
11. cd /opt/rabbitmq/sbin，./rabbitmqctl stop关闭rabbitmq
12. 这样就完成了安装
13. 启用管理方式（用网页方式管理MQ）cd /opt/rabbitmq/sbin/  
14. 执行./rabbitmq-plugin enable rabbitmq-management
15. 然后访问http://localhost:55672 

##四 RabbitMQ配置

一般情况下，RabbitMQ的默认配置就足够了。如果希望特殊设置的话，有两个途径：
一个是环境变量的配置文件 **rabbitmq-env.conf**
一个是配置信息的配置文件 **rabbitmq.config**
注意，这两个文件默认是没有的，如果需要必须自己创建。

####rabbitmq-env.conf
这个文件的位置是确定和不能改变的，位于：/etc/rabbitmq目录下（这个目录需要自己创建）。
文件的内容包括了RabbitMQ的一些环境变量，常用的有：
**RABBITMQ_NODE_PORT**=    //端口号

**HOSTNAME**=

**RABBITMQ_NODENAME**=mq

**RABBITMQ_CONFIG_FILE**=        //配置文件的路径

**RABBITMQ_MNESIA_BASE**=/rabbitmq/data        //需要使用的MNESIA数据库的路径

**RABBITMQ_LOG_BASE**=/rabbitmq/log        //log的路径

**RABBITMQ_PLUGINS_DIR**=/rabbitmq/plugins    //插件的路径

具体的列表见：[](http://www.rabbitmq.com/configure.html#define-environment-variables)

####rabbitmq.config
这是一个标准的erlang配置文件。它必须符合erlang配置文件的标准。
它既有默认的目录，也可以在*rabbitmq-env.conf*文件中配置。
文件的内容详见：[](http://www.rabbitmq.com/configure.html#config-items)

