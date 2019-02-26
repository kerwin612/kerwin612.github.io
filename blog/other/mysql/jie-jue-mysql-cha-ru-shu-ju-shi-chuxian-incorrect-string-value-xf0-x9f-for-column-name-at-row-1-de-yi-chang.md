#解决mysql插入数据时出现Incorrect string value: '\xF0\x9F...' for column 'name' at row 1的异常
**这个问题，原因是`UTF-8`编码有可能是两个、三个、四个字节。Emoji表情或者某些特殊字符是4个字节，而`MySQL`的utf8编码最多3个字节，所以数据插不进去。**

我的解决方案是这样的

1. 在mysql的安装目录下找到`my.ini`,作如下修改： 
```
[mysqld]
character-set-server=utf8mb4
[mysql]
default-character-set=utf8mb4
```
修改后重启`sudo service mysql restart`

2. 将已经建好的表也转换成`utf8mb4`
命令：`alter table TABLE_NAME convert to character set utf8mb4 collate utf8mb4_bin;`（将*TABLE_NAME*替换成你的表名）
