#MySQL长事务导致的Table Metadata Lock  

###什么是Table Metadata Lock
在MySQL以前的版本中，存在这样一个bug：
>Description:
If user1 has an active transaction on a table and then user2 drops this table, then user1 does COMMIT, then in the binlog we have something like:
DROP TABLE t;
BEGIN;
INSERT INTO t ... ;
COMMIT;
which is wrong.  

MySQL官方文档链接： [http://bugs.mysql.com/bug.php?id=989](http://bugs.mysql.com/bug.php?id=989)   
 
这个bug大致意思是说：当一个会话在主库执行DML操作还没提交时，另一个会话对同一个对象执行了`DDL`操作如`drop table`，而由于MySQL的`binlog`是基于事务提交的先后顺序进行记录的，因此在从库上应用时，就出现了先`drop table`，然后再向`table`中`insert`的情况，导致从库应用出错。

因此，MySQL在5.5.3版本后引入了`Metadata lock`，**只有在事务结束后才会释放Metadata lock，因此在事务提交或回滚前，是无法进行DDL操作的。**

MySQL官方文档位置：
http://dev.mysql.com/doc/refman/5.6/en/metadata-locking.html

###遇到的Metadata Lock问题
前几天时候，公司的开发同事让对一张表添加字段，由于该表数据量很大，因此使用了`pt-online-change-schema`工具进行字段的添加，在添加的过程中发现进度非常慢，通过`shop processlist`发现以及积累了大量的`Metadata lock`：**Waiting for table metadata lock**。

这些语句很明显是被添加字段的`DDL`所阻塞，但是`DDL`又是被谁阻塞了呢？

查询当前正在进行的事务：
```
mysql> select * from information_schema.innodb_trx\G
*************************** 1. row ***************************
                    trx_id: 7202
                 trx_state: RUNNING
               trx_started: 2016-07-20 23:02:53
     trx_requested_lock_id: NULL
          trx_wait_started: NULL
                trx_weight: 0
       trx_mysql_thread_id: 52402
                 trx_query: NULL
       trx_operation_state: NULL
         trx_tables_in_use: 0
         trx_tables_locked: 0
          trx_lock_structs: 0
     trx_lock_memory_bytes: 360
           trx_rows_locked: 0
         trx_rows_modified: 0
   trx_concurrency_tickets: 0
       trx_isolation_level: READ COMMITTED
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 10000
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
1 row in set (0.00 sec)
```
发现一个正在运行的事务，从`trx_started`字段可以判断出，该事务已经运行了很久，一直没有结束，看来就是这个事务阻塞了添加字段的DDL语句。

根据查询到的`trx_started`时间以及`trx_mysql_thread_id`到MySQL的`general log`中查找，当然前提是开启了`general log`的功能，在`general`日志中对应的时间发现该`thread`执行了语句：
`set autocommit=0;`
关闭了自动提交，再往下看，oh my god......下面居然是一堆`SELECT`语句！

好了，终于找到原因，`kill`掉先：
```
mysql> kill 52402;
Query OK, 0 rows affected (0.00 sec)
```
之后便可以正常执行下去了。
###测试验证
为了进一步确认问题的原因并验证，进行模拟测试：

* 会话1：显式开启事务，执行`SELECT`：  

```
mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from test;
+----------+
| date     |
+----------+
| 20150616 |
| 20150617 |
| 20150619 |
+----------+
3 rows in set (0.00 sec)
```
* 会话2：对test表执行DDL：  

```
mysql> alter table test add index `date`(`date`);
```
语句被阻塞，show processlist查看状态：
```
mysql> show processlist;
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
| Id    | User        | Host      | db   | Command | Time   | State                                                                       | Info                                      |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
|    16 | system user |           | NULL | Connect | 540155 | Waiting for master to send event                                            | NULL                                      |
|    17 | system user |           | NULL | Connect | 529732 | Slave has read all relay log; waiting for the slave I/O thread to update it | NULL                                      |
| 51673 | root        | localhost | test | Sleep   |     55 |                                                                             | NULL                                      |
| 51681 | root        | localhost | test | Query   |      0 | init                                                                        | show processlist                          |
| 51683 | root        | localhost | test | Query   |     29 | Waiting for table metadata lock                                             | alter table test add index `date`(`date`) |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
5 rows in set (0.00 sec)
```
可以看到`alter table`语句的状态为`Waiting for table metadata lock`

* 会话3：对test表进行查询：  

`mysql> select * from test;`
同样被阻塞：
```
mysql> show processlist;
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
| Id    | User        | Host      | db   | Command | Time   | State                                                                       | Info                                      |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
|    16 | system user |           | NULL | Connect | 540305 | Waiting for master to send event                                            | NULL                                      |
|    17 | system user |           | NULL | Connect | 529882 | Slave has read all relay log; waiting for the slave I/O thread to update it | NULL                                      |
| 51673 | root        | localhost | test | Sleep   |    205 |                                                                             | NULL                                      |
| 51681 | root        | localhost | test | Query   |      0 | init                                                                        | show processlist                          |
| 51683 | root        | localhost | test | Query   |    179 | Waiting for table metadata lock                                             | alter table test add index `date`(`date`) |
| 51703 | root        | localhost | test | Query   |     18 | Waiting for table metadata lock                                             | select * from test                        |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+-------------------------------------------+
6 rows in set (0.00 sec)
```  
---
接下来我们将 会话1 的事务提交，效果如下：

* 会话1：  
 
```
mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from test;
+----------+
| date     |
+----------+
| 20150616 |
| 20150617 |
| 20150619 |
+----------+
3 rows in set (0.00 sec)

mysql> commit;
Query OK, 0 rows affected (0.00 sec)
```
* 会话2：  

```
mysql> alter table test add index `date`(`date`);
Query OK, 0 rows affected (3 min 49.87 sec)
Records: 0  Duplicates: 0  Warnings: 0
```
* 会话3：

```
mysql> select * from test;
+----------+
| date     |
+----------+
| 20150616 |
| 20150617 |
| 20150619 |
+----------+
3 rows in set (1 min 8.27 sec)
```
* `show processlist`：  

```
mysql> show processlist;
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+------------------+
| Id    | User        | Host      | db   | Command | Time   | State                                                                       | Info             |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+------------------+
|    16 | system user |           | NULL | Connect | 540411 | Waiting for master to send event                                            | NULL             |
|    17 | system user |           | NULL | Connect | 529988 | Slave has read all relay log; waiting for the slave I/O thread to update it | NULL             |
| 51673 | root        | localhost | test | Sleep   |     55 |                                                                             | NULL             |
| 51681 | root        | localhost | test | Query   |      0 | init                                                                        | show processlist |
| 51683 | root        | localhost | test | Sleep   |    285 |                                                                             | NULL             |
| 51703 | root        | localhost | test | Sleep   |    124 |                                                                             | NULL             |
+-------+-------------+-----------+------+---------+--------+-----------------------------------------------------------------------------+------------------+
6 rows in set (0.00 sec)
```
可以看到，当会话1提交事务后，会话2和会话3的语句便可以正常执行了，由于被阻塞的原因，因此执行时间分别为 ( 3 min 49.87 sec ) 、( 1 min 8.27 sec )

###总结
* 对于纯SELECT操作来说，完全没有必要添加事务，MySQL的`innodb`是基于`MVCC`多版本控制，加事务没有任何意义
* 需要使用到事务时，也要尽量缩小事务的运行时间，一个事务中不要包含太多的语句