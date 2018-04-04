#com.mysql.jdbc.exceptions.jdbc4.CommunicationsException: Communications link failure  

![]()  

####具体报错–MySQL服务没启动同样报此错  
```
com.mysql.jdbc.exceptions.jdbc4.CommunicationsException: Communications link failure

The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
    at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
    at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:57)
    at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
    at java.lang.reflect.Constructor.newInstance(Constructor.java:526)
    at com.mysql.jdbc.Util.handleNewInstance(Util.java:404)
    at com.mysql.jdbc.SQLError.createCommunicationsException(SQLError.java:981)
    at com.mysql.jdbc.MysqlIO.readPacket(MysqlIO.java:628)
    at com.mysql.jdbc.MysqlIO.doHandshake(MysqlIO.java:1014)
    at com.mysql.jdbc.ConnectionImpl.coreConnect(ConnectionImpl.java:2255)
    at com.mysql.jdbc.ConnectionImpl.connectOneTryOnly(ConnectionImpl.java:2286)
    at com.mysql.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:2085)
    at com.mysql.jdbc.ConnectionImpl.<init>(ConnectionImpl.java:795)
    at com.mysql.jdbc.JDBC4Connection.<init>(JDBC4Connection.java:44)
    at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
    at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:57)
    at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
    at java.lang.reflect.Constructor.newInstance(Constructor.java:526)
    at com.mysql.jdbc.Util.handleNewInstance(Util.java:404)
    at com.mysql.jdbc.ConnectionImpl.getInstance(ConnectionImpl.java:400)
    at com.mysql.jdbc.NonRegisteringDriver.connect(NonRegisteringDriver.java:327)
    at org.mybatis.generator.internal.db.ConnectionFactory.getConnection(ConnectionFactory.java:68)
    at org.mybatis.generator.config.Context.getConnection(Context.java:526)
    at org.mybatis.generator.config.Context.introspectTables(Context.java:436)
    at org.mybatis.generator.api.MyBatisGenerator.generate(MyBatisGenerator.java:222)
    at org.mybatis.generator.api.MyBatisGenerator.generate(MyBatisGenerator.java:133)
    at GeneratorSqlmap.generator(GeneratorSqlmap.java:27)
    at GeneratorSqlmap.main(GeneratorSqlmap.java:33)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:606)
    at com.intellij.rt.execution.application.AppMain.main(AppMain.java:147)
Caused by: java.io.EOFException: Can not read response from server. Expected to read 4 bytes, read 0 bytes before connection was unexpectedly lost.
    at com.mysql.jdbc.MysqlIO.readFully(MysqlIO.java:2957)
    at com.mysql.jdbc.MysqlIO.readPacket(MysqlIO.java:560)
    ... 25 more
```


####分析  

**报错问题：** 
The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
最后一个发送成功的数据包在0秒前 没有收到任何来自服务器的数据包。

简单来说就是连不上MySQL服务器了

**检查MySQL连接是否有错**  
这时候你就得检查下你的msyql连接url有没有写错了
>driverClass="**com.mysql.jdbc.Driver**"
connectionURL="jdbc:mysql://**IP**:**3306**/**库名**"
userId="root"
password="**密码**"  

>ip 端口 库名 仔细检查下  

如果到这还没有解决问题 那么继续往下看

**检查Hosts文件**  
查看jdbc中的IP是否在hosts文件中有解析  
  
**检查MySQL配置文件**  
查看是否绑定ip地址  
如果有这行 注释`bind-address=xxx.xxx.xxx.xxx`  

**检查MySQL运行在哪个端口**
```
mysql> show global variables like 'port';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 3306  |
+---------------+-------+
1 row in set (0.10 sec)
```

**检查MySQL服务是否真正启动**  
`telnet Ip 3306`  

**检查MySQL是否不接受远程连接**  
```
SELECT USER,HOST FROM user;
//正确
+-----------+-----------+
| USER      | HOST      |
+-----------+-----------+
| root      | %         |
| mysql.sys | localhost |
| root      | localhost |
+-----------+-----------+
```
如果没有授权的话  
`mysql> grant all privileges on . to root@’%’ identified by ‘我是密码‘;`  

**检查MySQL是否已经用完了所有连接**  
重启MySQL 出现运行程序 如果不报错就是此问题  

**检查有没有什么东西在阻止Java程序和MySQL连接**  
比如关闭防火墙 或者设置防火墙规则  
比如有没有开什么代理  
比如拔网线 再连接MySQL试试  

