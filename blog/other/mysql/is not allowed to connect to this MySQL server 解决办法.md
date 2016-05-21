# is not allowed to connect to this MySQL server 解决办法

`ERROR 1130: Host ’192.168.1.3′ is not allowed to connect to this MySQL server`

处理方法有二个
1、(如何解决客户端与服务器端的连接(mysql) ：xxx.xxx.xxx.xxx is not allowed to connect to this mysql serv 
) 授权法。例如，你想myuser使用mypassword从任何主机连接到mysql服务器的话。
```sql
GRANT ALL PRIVILEGES ON *.* TO ‘myuser’@'%’ IDENTIFIED BY ‘mypassword’ WITH GRANT OPTION;
```
如果你想允许用户myuser从ip为192.168.1.3的主机连接到mysql服务器，并使用mypassword作为密码
```sql
GRANT ALL PRIVILEGES ON *.* TO ‘root’@’192.168.1.3′ IDENTIFIED BY ‘mypassword’ WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO ‘root’@’10.10.40.54′ IDENTIFIED BY ’123456′ WITH GRANT OPTION;
```

2、 改表法。可能是你的帐号不允许从远程登陆，只能在localhost。这个时候只要在localhost的那台电脑，登入mysql后，更改 “mysql” 数据库里的 “user” 表里的 “host” 项，从”localhost”改称”%”
这个是因为权限的问题，处理方式如下：
```shell
shell>mysql --user=root -pxxxxxx
mysql>use mysql
mysql>GRANT SELECT,INSERT,UPDATE,DELETE ON [db_name].* TO [username]@[ipadd] identified by '[password]';
```
`username`:远程登入的使用者代码
`db_name`:表示欲开放给使用者的数据库称
`password`:远程登入的使用者密码
`ipadd`:IP地址或者IP反查后的DNS Name，此例的内容需填入'60-248-32-13.HINET-IP.hinet.net' ，包函上引号(')
（其实就是在远端服务器上执行，地址填写本地主机的ip地址。）
也可以这样写
```shell
mysql -u root -pvmwaremysql>use mysql;mysql>update user set host = ‘%’ where user = ‘root’;mysql>select host, user from user;
```

执行了上面的语句后，再执行下面的语句，方可立即生效。
```shell
mysql>flush privileges; 
```