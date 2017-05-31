# MySQL备份--mysql dump

备份数据可以简单的使用命令：`mysqldump databasename > bak.sql`  
恢复数据可以简单的使用命令：`source bak.sql`  

windows 系统下需要把 *mysqldump.exe* 路径添加到环境变量 *PATH* 中，或者在命令行窗口中进入到 mysqldump.exe 目录下，windows下mysqldump.exe的路径大概为：C:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump.exe；Linux下的就更简单了，直接*whereis mysqldump*就可以知道mysqldump路径  

有些用户上边的命令就无法执行成功，必须使用以下命令：
```shell
mysqldump --user=root --password=root test > bak.sql
```
这是因为系统需要确定备份的用户具有读数据库的权限  

备份所有数据库：`mysqldump --all-databases > dump.sql`  
备份多个数据库：`mysqldump --databases db1 db2 db3 > dump.sql`  

下边是自己简单实现的可以在Linux 下通过crontab命令定时备份最新N个数据库的Python脚本
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