[wagon-maven-plugin](http://www.mojohaus.org/wagon-maven-plugin/)
```xml
<dependency>  
    <groupId>org.codehaus.mojo</groupId>  
    <artifactId>wagon-maven-plugin</artifactId>  
    <version>1.0</version>  
</dependency> 
```
主要提供如下几个`goal`
* [wagon:upload-single](http://www.mojohaus.org/wagon-maven-plugin/upload-single-mojo.html) uploads the specified file to a remote location.
* [wagon:upload](http://www.mojohaus.org/wagon-maven-plugin/upload-mojo.html) uploads the specified set of files to a remote location.
* [wagon:download-single](http://www.mojohaus.org/wagon-maven-plugin/download-single-mojo.html) downloads the specified file from a remote location.
* [wagon:download](http://www.mojohaus.org/wagon-maven-plugin/download-mojo.html) downloads the specified set of files from a remote location.
* [wagon:list](http://www.mojohaus.org/wagon-maven-plugin/list-mojo.html) lists the content of a specified location in a remote repository.
* [wagon:copy](http://www.mojohaus.org/wagon-maven-plugin/copy-mojo.html) copies a set of files under a Wagon repository to another.
* [wagon:merge-maven-repos](http://www.mojohaus.org/wagon-maven-plugin/merge-maven-repos-mojo.html) merges , including metadata, a Maven repository to another.
* [wagon:sshexec](http://www.mojohaus.org/wagon-maven-plugin/sshexec-mojo.html) Executes a set of commands at remote SSH host.  

使用前需要在`build`中加入
```xml
<build>
    [...]
    <extensions>  
        <extension>  
            <groupId>org.apache.maven.wagon</groupId>  
            <artifactId>wagon-ssh</artifactId>  
            <version>2.8</version>  
        </extension>  
    </extensions> 
    [...]
</build>
``` 
  
    
    
##文件上传到服务器
---
Maven项目可使用`mvn package`指令打包，打包完成后包位于`target`目录下，要想在远程服务器上部署，首先要将包上传到服务器。
在项目的`pom.xml`中配置`wagon-maven-plugin`插件：

####单个文件
```xml
<build>
	<extensions>
		<extension>
			<groupId>org.apache.maven.wagon</groupId>
			<artifactId>wagon-ssh</artifactId>
			<version>2.8</version>
		</extension>
	</extensions>
	<plugins>
		<plugin>
			<groupId>org.codehaus.mojo</groupId>
			<artifactId>wagon-maven-plugin</artifactId>
			<version>1.0</version>
			<configuration>
				<fromFile>target/test.jar</fromFile>
				<url>scp://user:password@server/home/xxg/Desktop</url>
			</configuration>
		</plugin>
	</plugins>
</build>
```

####多个文件
```xml
<build>
	<extensions>
		<extension>
			<groupId>org.apache.maven.wagon</groupId>
			<artifactId>wagon-ssh</artifactId>
			<version>2.8</version>
		</extension>
	</extensions>
	<plugins>
		<plugin>
			<groupId>org.codehaus.mojo</groupId>
			<artifactId>wagon-maven-plugin</artifactId>
			<version>1.0</version>
			<configuration>
				<fromDir>target</fromDir>
				<includes>lib/*,Hermes-service.jar</includes>
				<!-- <excludes>*</excludes> -->
				<url>scp://user:password@server</url>
				<toDir>/home/xxg/Desktop</toDir>
			</configuration>
		</plugin>
	</plugins>
</build>

```

`fromDir`是要上传的文件所在的目录
`includes`是要上传的文件的规则
`excludes`是无需上传的文件的规则
`toDir`是上传到服务器的所在目录
`fromFile`是要上传到服务器的文件，一般来说是jar或者war包   
`url`配置服务器的用户、密码、地址以及文件上传的目录。    

配置完成后，运行命令：  
```bash
mvn clean package wagon:upload-single
```    
`package`、`wagon:upload-single`分别对项目进行打包和上传操作。命令运行结束后，文件就会成功上传到Linux服务器。

##在服务器上执行Linux命令
---
部署项目不仅要把包传上服务器，而且还需要执行一些指令来启动程序。在程序启动之前，可能还需要将原来的程序关闭。
####运行jar文件
启动jar包通常会使用`java -jar test.jar`命令，可以将命令配置在`pom.xml`中：
```xml
<build>
	<extensions>
		<extension>
			<groupId>org.apache.maven.wagon</groupId>
			<artifactId>wagon-ssh</artifactId>
			<version>2.8</version>
		</extension>
	</extensions>
	<plugins>
		<plugin>
			<groupId>org.codehaus.mojo</groupId>
			<artifactId>wagon-maven-plugin</artifactId>
			<version>1.0</version>
			<configuration>
				<fromFile>target/test.jar</fromFile>
				<url>scp://user:password@server/home/xxg/Desktop</url>
				<commands>
					<!-- 杀死原来的进程 -->
					<command>pkill -f test.jar</command>
					<!-- 重新启动test.jar，程序的输出结果写到nohup.out文件中 -->
					<command>nohup java -jar /home/xxg/Desktop/test.jar > /home/xxg/Desktop/nohup.out 2>&1 &</command>
				</commands>
				<!-- 显示运行命令的输出结果 -->
				<displayCommandOutputs>true</displayCommandOutputs>
			</configuration>
		</plugin>
	</plugins>
</build>
```
配置完成后，运行命令：  
```bash
mvn clean package wagon:upload-single wagon:sshexec
```
`package`、`wagon:upload-single`、`wagon:sshexec`分别对项目进行打包、上传、运行`command`命令的操作。命令运行结束后，在服务器上查看进程`ps -ef|grep test.jar`，或者查看`nohup.out`文件，就可以看到Java程序在服务器上已经启动。  
####上传war包并启动Tomcat
如果是Web应用，可使用服务器上的Tomcat来部署。
```xml
<build>
	<extensions>
		<extension>
			<groupId>org.apache.maven.wagon</groupId>
			<artifactId>wagon-ssh</artifactId>
			<version>2.8</version>
		</extension>
	</extensions>
	<plugins>
		<plugin>
			<groupId>org.codehaus.mojo</groupId>
			<artifactId>wagon-maven-plugin</artifactId>
			<version>1.0</version>
			<configuration>
				<fromFile>target/javawebdeploy.war</fromFile>
				<!-- 上传到Tomcat的webapps目录下 -->
				<url>scp://user:password@server/coder/tomcat/apache-tomcat-7.0.55/webapps</url>
				<commands>
					<!-- 重启Tomcat -->
					<command>sh /coder/tomcat/apache-tomcat-7.0.55/bin/shutdown.sh</command>
					<command>rm -rf /coder/tomcat/apache-tomcat-7.0.55/webapps/javawebdeploy</command>
					<command>sh /coder/tomcat/apache-tomcat-7.0.55/bin/startup.sh</command>
				</commands>
				<displayCommandOutputs>true</displayCommandOutputs>
			</configuration>
		</plugin>
	</plugins>
</build>
```
完成以上配置后，同样可通过`mvn clean package wagon:upload-single wagon:sshexec`命令自动部署。  

##配置execution
---
如果你觉得`mvn clean package wagon:upload-single wagon:sshexec`命令太长了不好记，那么可以配置`execution`，在运行`package`打包的同时运行`upload-single`和`sshexec`。  
```xml
<build>
	<extensions>
		<extension>
			<groupId>org.apache.maven.wagon</groupId>
			<artifactId>wagon-ssh</artifactId>
			<version>2.8</version>
		</extension>
	</extensions>
	<plugins>
		<plugin>
			<groupId>org.codehaus.mojo</groupId>
			<artifactId>wagon-maven-plugin</artifactId>
			<version>1.0</version>
			<executions>
				<execution>
					<id>upload-deploy</id>
					<!-- 运行package打包的同时运行upload-single和sshexec -->
					<phase>package</phase>
					<goals>
						<goal>upload-single</goal>
						<goal>sshexec</goal>
					</goals>
					<configuration>
						<fromFile>${project.build.directory}/${project.build.finalName}.${project.packaging}</fromFile>
						<url>scp://user:password@server/coder/tomcat/apache-tomcat-7.0.55/webapps</url>
						<commands>
							<command>
								<![CDATA[
                                    export JAVA_HOME=/opt/jdk1.8.0_121
                                    export PATH=$JAVA_HOME/bin:$PATH
                                    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
                                    cd /opt/mircroService/pcs && ./run.sh start
                                ]]>
							</command>
							<command>sh /coder/tomcat/apache-tomcat-7.0.55/bin/shutdown.sh</command>
							<command>rm -rf /coder/tomcat/apache-tomcat-7.0.55/webapps/javawebdeploy</command>
							<command>sh /coder/tomcat/apache-tomcat-7.0.55/bin/startup.sh</command>
						</commands>
						<displayCommandOutputs>true</displayCommandOutputs>
					</configuration>
				</execution>
			</executions>
		</plugin>
	</plugins>
</build>
```
配置完成后，即可使用`mvn clean package`来代替`mvn clean package wagon:upload-single wagon:sshexec`。  

##服务器独立配置  
需要在Maven的配置文件`settings.xml`中配置好`server`的用户名和密码。
```xml
<server>  
    <id>webserver</id>  
    <username>hadoop</username>  
    <password>123</password>  
<!--
<configuration>
	diabled `The authenticity of host 'xxx' can't be established.Are you sure you want to continue connecting? (yes/no):`
	<strictHostKeyChecking>no</strictHostKeyChecking>
	or
	<knownHostsProvider implementation="org.apache.maven.wagon.providers.ssh.knownhost.NullKnownHostProvider">
		<hostKeyChecking>no</hostKeyChecking>
	</knownHostsProvider>
</configuration>
-->
</server>
```
然后`configuration`里面加上`serverId`，并且去掉`url`里面的用户名和密码。
```xml
<configuration>
	[...]
	<serverId>webserver</serverId>
	<url>scp://server</url>
	[...]
<configuration>
```  

引用：  
http://blog.csdn.net/mn960mn/article/details/49560003  
http://xxgblog.com/2015/10/23/wagon-maven-plugin/