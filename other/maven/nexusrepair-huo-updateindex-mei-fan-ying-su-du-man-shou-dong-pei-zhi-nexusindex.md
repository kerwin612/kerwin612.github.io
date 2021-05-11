# nexus repair或update index 没反应 速度慢 手动配置nexus index

访问 [http://repo.maven.apache.org/maven2/.index/](http://repo.maven.apache.org/maven2/.index/) 下载中心仓库最新版本的索引文件，在一长串列表中，我们需要下载如下两个文件（一般在列表的末尾位置）  
[nexus-maven-repository-index.gz](http://repo1.maven.org/maven2/.index/nexus-maven-repository-index.gz) [nexus-maven-repository-index.properties](http://repo1.maven.org/maven2/.index/nexus-maven-repository-index.properties)  
下载完成之后最好是通过md5或者sha1校验一下文件是否一致，因为服务器并不在国内，网络传输可能会造成文件损坏。  
下面就是解压这个索引文件，虽然后缀名为gz，但解压方式却比较特别，我们需要下载一个jar包 [indexer-cli-5.1.1.jar](https://repo1.maven.org/maven2/org/apache/maven/indexer/indexer-cli/5.1.1/indexer-cli-5.1.1.jar) ，我们需要通过这个特殊的jar来解压这个索引文件  
将上面三个文件（.gz & .properties & .jar）放置到同一目录下，运行如下命令  
`java -jar indexer-cli-5.1.1.jar -u nexus-maven-repository-index.gz -d indexer`

等待程序运行完成之后可以发现indexer文件夹下出现了很多文件，将这些文件放置到{nexus-home}/sonatype-work/nexus/indexer/central-ctx目录下，重新启动nexus

