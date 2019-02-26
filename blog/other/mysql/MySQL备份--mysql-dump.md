# MySQL备份--mysql dump

```bash
Dumping structure and contents of MySQL databases and tables.
Usage: mysqldump [OPTIONS] database [tables]
OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
OR     mysqldump [OPTIONS] --all-databases [OPTIONS]
```

`mysqldump [OPTIONS] database [tables]`  如果你不给定任何表，整个数据库将被导出。

通过执行`mysqldump --help`，你能得到你`mysqldump`的版本支持的选项表。

注意，如果你运行`mysqldump`没有`--quick`或`--opt`选项，`mysqldump`将在导出结果前装载整个结果集到内存中，如果你正在导出一个大的数据库，这将可能是一个问题。

备份数据可以简单的使用命令：`mysqldump databasename > bak.sql`  
恢复数据可以简单的使用命令：`source bak.sql`

windows 系统下需要把 `mysqldump.exe` 路径添加到环境变量 `PATH` 中，或者在命令行窗口中进入到 `mysqldump.exe` 目录下，windows下`mysqldump.exe`的路径大概为：`C:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump.exe`；Linux下的就更简单了，直接`whereis mysqldump`就可以知道`mysqldump`路径

有些用户上边的命令就无法执行成功，必须使用以下命令：

```shell
mysqldump --user=root --password=root test > bak.sql
```

这是因为系统需要确定备份的用户具有读数据库的权限

* 备份所有数据库\(包含数据\)：`mysqldump --all-databases > dump.sql`                                                                                                      
* 备份多个数据库\(包含数据\)：`mysqldump --databases db1 db2 db3 > dump.sql`                                                                                       
* 备份指定数据表\(包含数据\)：`mysqldump --databases db1 --tables tb1 tb2 > dump.sql`                                                                      
* 备份指定表结构\(不包含数据\)：`mysqldump --no-data --databases db --tables tb1 tb2 > dump.sql`

下边是自己简单实现的可以在Linux 下通过`crontab`命令定时备份最新N个数据库的Python脚本

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#@arthur  
#@date    2015-05-7
#@dsc     远程备份s数据

import os
import sys
import logging
import traceback
import time

logger = logging.getLogger()
logging.basicConfig(
                    format = '%(asctime)s %(levelname)s %(module)s.%(funcName)s Line:%(lineno)d\t%(message)s',
                    filename = os.path.join(os.path.dirname(__file__), r'backStrategyData.log'),
                    filemode = 'a+',
                    level = logging.NOTSET
                    )

class BackupDatabase():
    '''
    备份数据库
    '''
    def __init__(self, dbIp, dbName, bakFile, user, pwd):
        self.dbIp = dbIp
        self.dbName = dbName
        self.bakFile = bakFile
        self.user =user
        self.pwd = pwd

    def __generateCmd(self):
        cmd = 'mysqldump --host %s --user=%s --password=%s %s > %s' \
            % (self.dbIp, self.user, self.pwd, self.dbName, self.bakFile)
        return cmd    

    def runBackup(self):
        cmd = self.__generateCmd()
        try:
            os.system(cmd)
        except:
            logger.error(traceback.format_exc())

#数据库ip
__mysqlIp = ''
__bakPath = r'/data/backup/strategydata'
__dbName = 'strategydata'
__user = ''
__pwd = ''
# 备份个数
__bakCount = 5
# 备份文件后缀
__bakSuffix = 'strategydata.sql'

def backStrategyData():
    files = os.listdir(__bakPath)
    bakFiles = []
    for f in files:
        if os.path.isfile(os.path.join(__bakPath, f)) and f.endswith(__bakSuffix):
            bakFiles.append(f)
    bakFiles.sort(reverse=True)
    delFiles = bakFiles[__bakCount - 1:]
    try:
        for f in delFiles:
            df = os.path.join(__bakPath, f)
            logger.info('delete file %s.' % df)
            os.remove(df)
    except:
        logger.error(traceback.format_exc())
    newBakFile = os.path.join(__bakPath, time.strftime("%Y-%m-%d-%H-%M-%S") + __bakSuffix)
    logger.info('backup %s:%s to %s!' % (__mysqlIp, __dbName, newBakFile))
    oBack = BackupDatabase(__mysqlIp, __dbName, newBakFile, __user, __pwd)
    oBack.runBackup()


def main():
    try:
        backStrategyData()
    except:
        logger.error(traceback.format_exc())

if __name__ == '__main__':
    main()
```


**mysqldump备份：**  
`mysqldump -u用户名 -p密码 -h主机 数据库 a -w "sql条件" --lock-all-tables > 路径`  
eg:`mysqldump -uroot -p1234 -hlocalhost db1 a -w "id in (select id from b)" --lock-all-tables > c:\aa.txt`  

**mysqldump还原：**  
`mysqldump -u用户名 -p密码 -h主机 数据库 < 路径`  
eg:`mysql -uroot -p1234 db1 < c:\aa.txt`  

**mysqldump按条件导出：**  
`mysqldump -u用户名 -p密码 -h主机 数据库  a --where "条件语句" --no-建表> 路径`  
eg:`mysqldump -uroot -p1234 dbname a --where "tag='88'" --no-create-info> c:\a.sql`  

**mysqldump按导入：**  
`mysqldump -u用户名 -p密码 -h主机 数据库 < 路径`  
eg:`mysql -uroot -p1234 db1 < c:\a.txt`  

**mysqldump导出表：**  
`mysqldump -u用户名 -p密码 -h主机 数据库 表`  
eg:`mysqldump -uroot -p sqlhk9 a --no-data`  


**讲一下 mysqldump 的一些主要参数**
* `--compatible=name`  
    它告诉`mysqldump`，导出的数据将和哪种数据库或哪个旧版本的`MySQL`服务器相兼容。值可以为`ansi`、`mysql323`、`mysql40`、`postgresql`、`oracle`、`mssql`、`db2`、`maxdb`、`no_key_options`、`no_tables_options`、`no_field_options`等，要使用几个值，用逗号将它们隔开。当然了，它并不保证能完全兼容，而是尽量兼容。 
* `--complete-insert，-c`  
    导出的数据采用包含字段名的完整`INSERT`方式，也就是把所有的值都写在一行。这么做能提高插入效率，但是可能会受到`max_allowed_packet`参数的影响而导致插入失败。因此，需要谨慎使用该参数，至少我不推荐。 
* `--default-character-set=charset`  
    指定导出数据时采用何种字符集，如果数据表不是采用默认的`latin1`字符集的话，那么导出时必须指定该选项，否则再次导入数据后将产生乱码问题。  
* `--disable-keys`  
    告诉`mysqldump`在`INSERT`语句的开头和结尾增加`/*!40000 ALTER TABLE table DISABLE KEYS */;`和`/*!40000 ALTER TABLE table ENABLE KEYS */;`语句，这能大大提高插入语句的速度，因为它是在插入完所有数据后才重建索引的。该选项只适合`MyISAM`表。  
* `--extended-insert = true|false`  
    默认情况下，`mysqldump`开启`--complete-insert`模式，因此不想用它的的话，就使用本选项，设定它的值为`false`即可。   
* `--hex-blob`  
    使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用本选项。影响到的字段类型有 `BINARY`、`VARBINARY`、`BLOB`。
* `--lock-all-tables，-x`  
    在开始导出之前，提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭`--single-transaction`和`--lock-tables`选项。  
* `--lock-tables `  
    它和`--lock-all-tables`类似，不过是锁定当前导出的数据表，而不是一下子锁定全部库下的表。本选项只适用于`MyISAM`表，如果是`Innodb`表可以用`--single-transaction`选项。  
* `--no-create-info，-t`  
    只导出数据，而不添加`CREATE TABLE`语句。  
* `--no-data，-d`  
    不导出任何数据，只导出数据库表结构。  
* `--opt`  
    这只是一个快捷选项，等同于同时添加`--add-drop-tables` `--add-locking` `--create-option` `--disable-keys` `--extended-insert` `--lock-tables` `--quick` `--set-charset`选项。本选项能让`mysqldump`很快的导出数据，并且导出的数据能很快导回。该选项默认开启，但可以用`--skip-opt`禁用。注意，如果运行`mysqldump`没有指定`--quick`或`--opt`选项，则会将整个结果集放在内存中。如果导出大数据库的话可能会出现问题。  
* `--quick，-q`  
    该选项在导出大表时很有用，它强制`mysqldump`从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中。
* `--routines，-R`  
    导出存储过程以及自定义函数。
* `--single-transaction`  
    该选项在导出数据之前提交一个`BEGIN` SQL语句，`BEGIN`不会阻塞任何应用程序且能保证导出时数据库的一致性状态。它只适用于事务表，例如`InnoDB`和`BDB`。
本选项和`--lock-tables`选项是互斥的，因为`LOCK TABLES`会使任何挂起的事务隐含提交。
要想导出大表的话，应结合使用`--quick`选项。
* `--triggers`  
    同时导出触发器。该选项默认启用，用`--skip-triggers`禁用它。