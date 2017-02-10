###SELinux概述
    
**SELinux**(Secure Enhanced Linux)是为Linux开发的一个强制访问控制模块，在内核2.6版本后集成于内核中，定义了访问文件的各种策略。与传统linux不同的是，**SELinux**对于资源的管理，不再通过用户级别和权限级别的方式实现，而是将资源抽象为***对象object***，并且为其赋予特定的*安全标签*保存其于元数据中，通过***主体subject(进程就是主体)***检查策略中的条目，从而限制资源的开放性。使得系统处于MAC环境下。
***这里的资源可以是文件、端口......***

    DAC：Discretionary Access Control 自由访问控制
    MAC：Mandatory Access Control 强制访问控制

**SELinux**使用所谓的**MAC**，他可以针对特定的程序与特定的档案资源来进行权限的控管！ 也就是说，即使你是 root ，那么在使用不同的程序时，你所能取得的权限并不一定是 root ，而得要看当时该程序的设定而定。 如此一来，我们针对控制的『主体』变成了『程序』而不是『使用者』喔！因此，这个权限的管理模式就特别适合网络服务的『程序』了！ 因为，即使你的程序使用 root 的身份去启动，如果这个程序被攻击而被取得操作权，那该程序能作的事情还是有限的， 因为被 **SELinux** 限制住了能进行的工作了嘛！

举例来说， WWW 服务器软件的达成程序为 httpd 这支程序， 而默认情况下， httpd 仅能在 /var/www/ 这个目录底下存取档案，如果 httpd 这个程序想要到其他目录去存取数据时，除了规则设定要开放外，目标目录也得要设定成 httpd 可读取的模式 (type) 才行喔！限制非常多！ 所以，即使不小心 httpd 被 cracker 取得了控制权，他也无权浏览 /etc/shadow 等重要的配置文件喔！    

-----

####SELinux 的运作模式

再次的重复说明一下，**SELinux**是透过**MAC**的方式来控管程序，他控制的主体是程序， 而目标则是该程序能否读取的『档案资源』！所以先来说明一下这些咚咚的相关性啦！

* **主体** (Subject)：
SELinux 主要想要管理的就是程序，因此你可以将『主体』跟本章谈到的 **process** 划上等号；

* **目标** (Object)：
主体程序能否存取的『目标资源』一般就是文件系统。因此这个目标项目可以等文件系统划上等号；

* **政策** (Policy)：
由于程序与档案数量庞大，因此 SELinux 会依据某些服务来制订基本的存取安全性政策。这些政策内还会有详细的规则 (rule) 来指定不同的服务开放某些资源的存取与否。在目前的 CentOS 6.x 里面仅有提供两个主要的政策如下，一般来说，使用预设的 **target** 政策即可。

    * **targeted**：**针对网络服务限制较多，针对本机限制较少，是预设的政策**；
    * mls：完整的 SELinux 限制，限制方面较为严格。

* **安全性本文** (security context)：
我们刚刚谈到了主体、目标与政策面，但是主体能不能存取目标除了要符合政策指定之外，**主体与目标的安全性本文必须一致才能够顺利存取**。 这个安全性本文 (security context) 有点类似文件系统的 rwx 啦！安全性本文的内容与设定是非常重要的！ 如果设定错误，你的某些服务(主体程序)就无法存取文件系统(目标资源)，当然就会一直出现『权限不符』的错误讯息了！
![]()  
上图的重点在『主体』如何取得『目标』的资源访问权限！ 由上图我们可以发现，  
1. 主体程序必须要通过 SELinux 政策内的规则放行后，就可以与目标资源进行安全性本文的比对，   
2. 若比对失败则无法存取目标，若比对成功则可以开始存取目标。问题是，最终能否存取目标还是与文件系统的 rwx 权限设定有关喔！如此一来，加入了 SELinux 之后，出现权限不符的情况时，你就得要一步一步的分析可能的问题了！   

-----  

####安全性本文 (Security Context)

CentOS 6.x 的 target 政策已经帮我们制订好非常多的规则了，因此你只要知道如何开启/关闭某项规则的放行与否即可。 那个安全性本文比较麻烦！因为你可能需要自行配置文件案的安全性本文呢！为何需要自行设定啊？ 举例来说，你不也常常进行档案的 rwx 的重新设定吗？这个安全性本文你就将他想成 SELinux 内必备的 rwx 就是了！这样比较好理解啦。

安全性本文存在于主体程序中与目标档案资源中。程序在内存内，所以安全性本文可以存入是没问题。 那档案的安全性本文是记录在哪里呢？事实上，安全性本文是放置到档案的 inode 内的，因此主体程序想要读取目标档案资源时，同样需要读取 inode ， 这 inode 内就可以比对安全性本文以及 rwx 等权限值是否正确，而给予适当的读取权限依据。

那么安全性本文到底是什么样的存在呢？我们先来看看 /root 底下的档案的安全性本文好了。 观察安全性本文可使用『 `ls -Z` 』去观察如下：(注意：你必须已经启动了 SELinux 才行！若尚未启动，这部份请稍微看过一遍即可。底下会介绍如何启动 SELinux 喔！)
```shell
[root@www ~]# ls -Z
-rw-------. root  root  system_u:object_r:admin_home_t:s0     anaconda-ks.cfg
drwxr-xr-x. root  root  unconfined_u:object_r:admin_home_t:s0 bin
-rw-r--r--. root  root  system_u:object_r:admin_home_t:s0     install.log
-rw-r--r--. root  root  system_u:object_r:admin_home_t:s0     install.log.syslog
# 上述特殊字体的部分，就是安全性本文的内容！
```
如上所示，安全性本文主要用冒号分为三个字段 (最后一个字段先略过不看)，这三个字段的意义为：
```shell
Identify:role:type
身份识别:角色:类型
```
* **身份识别** (Identify)： 相当于账号方面的身份识别！主要的身份识别则有底下三种常见的类型：

    * **root**：表示 root 的账号身份，如同上面的表格显示的是 root 家目录下的数据啊！
    * **system_u**：表示系统程序方面的识别，通常就是程序啰；
    * **user_u**：代表的是一般使用者账号相关的身份。

* **角色** (Role)： 透过角色字段，我们可以知道这个数据是属于程序、档案资源还是代表使用者。一般的角色有：

    * **object_r**：代表的是档案或目录等档案资源，这应该是最常见的啰；
    * **system_r**：代表的就是程序啦！不过，一般使用者也会被指定成为 system_r 喔！

* **类型** (Type)： 在预设的 targeted 政策中， Identify 与 Role 字段基本上是不重要的！重要的在于这个类型 (type) 字段！ 基本上，一个主体程序能不能读取到这个档案资源，与类型字段有关！而类型字段在档案与程序的定义不太相同，分别是：

    * **type**：在档案资源 (Object) 上面称为类型 (Type)；
    * **domain**：在主体程序 (Subject) 则称为领域 (domain) 了！

domain 需要与 type 搭配，则该程序才能够顺利的读取档案资源啦！

-----  

####程序与档案 SELinux type 字段的相关性
那么这三个字段如何利用呢？首先我们来瞧瞧主体程序在这三个字段的意义为何！透过身份识别与角色字段的定义， 我们可以约略知道某个程序所代表的意义喔！基本上，这些对应资料在 targeted 政策下的对应如下：

| :---: |:---: | :---: |     
|身份识别|角色|该对应在 targeted 的意义|    
| :--- |:--- | :--- |   
|root|system_r|代表供 root 账号登入时所取得的权限|  
|system_u|system_r|由于为系统账号，因此是非交谈式的系统运作程序|   
|user_u|system_r|一般可登入用户的程序啰！|   

但就如上所述，其实最重要的字段是类型字段，主体与目标之间是否具有可以读写的权限，与程序的 domain 及档案的 type 有关！这两者的关系我们可以使用达成 WWW 服务器功能的 httpd 这支程序与 /var/www/html 这个网页放置的目录来说明。 首先，看看这两个咚咚的安全性本文内容先：
```shell
[root@www ~]# yum install httpd
[root@www ~]# ll -Zd /usr/sbin/httpd /var/www/html
-rwxr-xr-x. root root system_u:object_r:httpd_exec_t:s0 /usr/sbin/httpd
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 /var/www/html
# 两者的角色字段都是 object_r ，代表都是档案！而 httpd 属于 httpd_exec_t 类型，
# /var/www/html 则属于 httpd_sys_content_t 这个类型！
```
httpd 属于 httpd_exec_t 这个可以执行的类型，而 /var/www/html 则属于 httpd_sys_content_t 这个可以让 httpd 领域 (domain) 读取的类型。文字看起来不太容易了解吧！我们使用图示来说明这两者的关系！
图片1
上图的意义我们可以这样看的：  

1. 首先，我们触发一个可执行的目标档案，那就是具有 httpd_exec_t 这个类型的 /usr/sbin/httpd
2. 该档案的类型会让这个档案所造成的主体程序 (Subject) 具有 httpd 这个领域 (domain)， 我们的政策针对这个领域已经制定了许多规则，其中包括这个领域可以读取的目标资源类型；
3. 由于 httpd domain 被设定为可以读取 httpd_sys_content_t 这个类型的目标档案 (Object)， 因此你的网页放置到 /var/www/html/ 目录下，就能够被 httpd 那支程序所读取了；
4. 但最终能不能读到正确的资料，还得要看 rwx 是否符合 Linux 权限的规范！   


上述的流程告诉我们几个重点，第一个是政策内需要制订详细的 domain/type 相关性；第二个是若档案的 type 设定错误， 那么即使权限设定为 rwx 全开的 777 ，该主体程序也无法读取目标档案资源的啦！不过如此一来， 也就可以避免用户将他的家目录设定为 777 时所造成的权限困扰。

-----  

###SELinux 的启动、关闭与观察

并非所有的 Linux distributions 都支持 SELinux 的，所以你必须要先观察一下你的系统版本为何！ 鸟哥这里介绍的 CentOS 6.x 本身就有支持 SELinux 啦！所以你不需要自行编译 SELinux 到你的 Linux 核心中！ 目前 SELinux 支持三种模式，分别如下：

* **enforcing**：强制模式，代表 SELinux 运作中，且已经正确的开始限制 domain/type 了；
* **permissive**：宽容模式：代表 SELinux 运作中，不过仅会有警告讯息并不会实际限制 domain/type 的存取。这种模式可以运来作为 SELinux 的 debug 之用；
* **disabled**：关闭，SELinux 并没有实际运作。
那你怎么知道目前的 SELinux 模式呢？就透过 getenforce 吧！
```shell
[root@www ~]# getenforce
Enforcing  <==诺！就显示出目前的模式为 Enforcing 啰！
```
另外，我们又如何知道 SELinux 的政策 (Policy) 为何呢？这时可以来观察配置文件啦：
```shell
[root@www ~]# vim /etc/selinux/config
SELINUX=enforcing     <==调整 enforcing|disabled|permissive
SELINUXTYPE=targeted  <==目前仅有 targeted 与 mls
```

-----  

####SELinux 的启动与关闭

上面是默认的政策与启动的模式！你要注意的是，如果改变了政策则需要重新启动；如果由 enforcing 或 permissive 改成 disabled ，或由 disabled 改成其他两个，那也必须要重新启动。这是因为 SELinux 是整合到核心里面去的， 你只可以在 SELinux 运作下切换成为强制 (enforcing) 或宽容 (permissive) 模式，不能够直接关闭 SELinux 的！ 如果刚刚你发现 getenforce 出现 disabled 时，请到上述档案修改成为 enforcing 然后重新启动吧！

不过你要注意的是，如果从 disable 转到启动 SELinux 的模式时， 由于系统必须要针对档案写入安全性本文的信息，因此开机过程会花费不少时间在等待重新写入 SELinux 安全性本文 (有时也称为 SELinux Label) ，而且在写完之后还得要再次的重新启动一次喔！你必须要等待粉长一段时间！ 等到下次开机成功后，再使用 getenforce 来观察看看有否成功的启动到 Enforcing 的模式啰！

如果你已经在 Enforcing 的模式，但是可能由于一些设定的问题导致 SELinux 让某些服务无法正常的运作， 此时你可以将 Enforcing 的模式改为宽容 (permissive) 的模式，让 SELinux 只会警告无法顺利联机的讯息， 而不是直接抵挡主体程序的读取权限。让 SELinux 模式在 enforcing 与 permissive 之间切换的方法为：
```shell
[root@www ~]# setenforce [0|1]
选项与参数：
0 ：转成 permissive 宽容模式；
1 ：转成 Enforcing 强制模式

# 范例一：将 SELinux 在 Enforcing 与 permissive 之间切换与观察
[root@www ~]# setenforce 0
[root@www ~]# getenforce
Permissive
[root@www ~]# setenforce 1
[root@www ~]# getenforce
Enforcing
```
不过请注意， setenforce 无法在 Disabled 的模式底下进行模式的切换喔！
>Tips:
在某些特殊的情况底下，你从 Disabled 切换成 Enforcing 之后，竟然有一堆服务无法顺利启动，都会跟你说在 /lib/xxx 里面的数据没有权限读取，所以启动失败。这大多是由于在重新写入 SELinux type (Relable) 出错之故，使用 Permissive 就没有这个错误。那如何处理呢？最简单的方法就是在 Permissive 的状态下，使用『 restorecon -Rv / 』重新还原所有 SELinux 的类型，就能够处理这个错误！  

-----  

###SELinux type 的修改
