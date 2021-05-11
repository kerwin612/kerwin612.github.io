# MySQL修改root密码的多种方法

方法1： 用`SET PASSWORD`命令

```text
mysql -u root
mysql> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('newpass');
```

方法2：用`mysqladmin`

```text
mysqladmin -u root password "newpass"
如果root已经设置过密码，采用如下方法
mysqladmin -u root password oldpass "newpass"
```

方法3： 用`UPDATE`直接编辑`user`表

```text
mysql -u root
mysql> use mysql;
mysql> UPDATE user SET Password = PASSWORD('newpass') WHERE user = 'root';
mysql> FLUSH PRIVILEGES;
```

在丢失`root密码`的时候，可以这样

```text
mysqld_safe --skip-grant-tables&
mysql -u root mysql
mysql> UPDATE user SET password = PASSWORD("new password") WHERE user='root';
mysql> FLUSH PRIVILEGES;
```

