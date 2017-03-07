# Mysql启动中 InnoDB: Error: log file ./ib_logfile0 is of different size 0 5242880 bytes 的问题

如果你的配置文件使用了类似 my-innodb-heavy-4G.cnf 作为配置文件的话。   
Mysql 可以正常启动，但 innodb 的表无法使用   
在错误日志里你会看到如下输出：   
`InnoDB: Error: log file ./ib_logfile0 is of different size 0 5242880 bytes`   

现在需要做的事情就是把原来的 innodb 的 ib_logfile× 备份到一个目录下，然后删除掉原来的文件，重启 mysql。   
你会看到 ib_logfile\* 大小变成了你配置文件中指定的大小。   
my-innodb-heavy-4G.cnf 的话（log file 的大小是256M：innodb_log_file_size = 256M）     
你会看到很多个268435456大小的文件。  