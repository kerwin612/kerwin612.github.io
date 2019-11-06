#SpringBoot启动后 Stopping service [Tomcat]  

SpringBoot启动后一直Stopping service [Tomcat] ，没有具体详细的错误信息供定位问题，提示信息如下：
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