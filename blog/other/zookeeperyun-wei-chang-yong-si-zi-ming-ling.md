#Zookeeper运维常用四字命令

* `echo stat | nc 127.0.0.1 2181` 查看哪个节点被选择作为`follower`或者`leader`
* `echo ruok | nc 127.0.0.1 2181` 测试是否启动了该`server`，若回复`imok`表示已经启动。
* `echo dump | nc 127.0.0.1 2181` 列出未经处理的会话和临时节点。
* `echo kill | nc 127.0.0.1 2181` 关掉`server`
* `echo conf | nc 127.0.0.1 2181` 输出相关服务配置的详细信息。
* `echo cons | nc 127.0.0.1 2181` 列出所有连接到服务器的客户端的完全的连接 / 会话的详细信息。
* `echo envi | nc 127.0.0.1 2181` 输出关于服务环境的详细信息（区别于 `conf` 命令）。
* `echo reqs | nc 127.0.0.1 2181` 列出未经处理的请求。
* `echo wchs | nc 127.0.0.1 2181` 列出服务器 `watch` 的详细信息。
* `echo wchc | nc 127.0.0.1 2181` 通过 `session` 列出服务器 `watch` 的详细信息，它的输出是一个与 `watch` 相关的会话的列表。
* `echo wchp | nc 127.0.0.1 2181` 通过路径列出服务器 `watch` 的详细信息。它输出一个与 `session` 相关的路径。  
  
连接到`ZooKeeper`服务 `./zkCli.sh -server localhost:2181`  
`ls`(查看当前节点数据)    
`ls2`(查看当前节点数据并能看到更新次数等数据)     
`create`(创建一个节点)    
`get`(得到一个节点，包含数据和更新次数等数据)   
`set`(修改节点)   
`delete`(删除一个节点)     

转：http://www.hollischuang.com/archives/1208