#SpringBoot启动后 Stopping service [Tomcat]  

`Spring Boot`启动后一直`Stopping service [Tomcat]` ，没有具体详细的错误信息供定位问题，提示信息如下：
```
HikariPool-1 - Shutdown completed
Stopping service [Tomcat]
```   

加上`log4j`的配置，显现出更多的信息来定位问题。在`resources`目录下新建配置`log4j.properties`  
```
log4j.rootLogger=INFO, A1
log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
```

ref：https://www.jianshu.com/p/114ab1de712a  

仔细观察项目启动日志可以发现，启动时有两条警告信息：
```
log4j:WARN No appenders could be found for logger (org.springframework.web.context.ContextLoader). 
log4j:WARN Please initialize the log4j system properly.
```  
由于历史原因，`Spring`的日志使用的是`JCL`，`Spring Boot`是用的`slf4j+logback`，我们只需要将`JCL`和`Slf4j`桥接一下，`Spring`就会使用项目的日志配置，所以引入依赖即可：
```
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>jcl-over-slf4j</artifactId>
    <version>1.7.25</version>
</dependency>
```  

ref: https://my.oschina.net/icebergxty/blog/1808341