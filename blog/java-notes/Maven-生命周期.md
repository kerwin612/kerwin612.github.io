# Maven - 构建生命周期

## 什么是构建生命周期 {#f307d87ec11f2230b84f61b226e59882}

构建生命周期（Build Lifecycle）是一组 阶段（**phase**）** **的序列（sequence of phases），每个阶段（**phase**）定义了目标（**goal**）被执行的顺序（order）。这里的 **phase **是生命周期（Build Lifecycle）的一部分。

举例说明，一个典型的 Maven 构建生命周期是由以下几个 **phase **的序列组成的：

| 阶段（**phase**） | 处理 | 描述 |
| :--- | :--- | :--- |
| prepare-resources | 资源拷贝 | 本阶段可以自定义需要拷贝的资源 |
| compile | 编译 | 本阶段完成源代码编译 |
| package | 打包 | 本阶段根据 pom.xml 中描述的打包配置创建 JAR / WAR 包 |
| install | 安装 | 本阶段在本地 / 远程仓库中安装工程包 |

当需要在某个特定 **phase **之前或之后执行 **goal **时，可以使用`pre`和`post`来定义这个 **goal **。

当 Maven 开始构建工程，会按照所定义的 **phase **序列的顺序执行每个阶段注册的 **goal **。Maven 有以下三个标准的生命周期：

* clean
* default\(or build\)
* site

> **goal **表示一个特定的、对构建和管理工程有帮助的任务。它可能绑定了 0 个或多个构建 **phase **。
>
> 没有绑定任何构建 **phase **的 **goal **可以在构建生命周期之外被直接调用执行。

执行的顺序依赖于 **goal **和构建 **phase **被调用的顺序。例如，考虑下面的命令。`clean` 和 `package` 参数是构建 **phase **，而 `dependency:copy-dependencies` 是一个 **goal **。

```
mvn clean dependency:copy-dependencies package
```

这里的 `clean`  **phase **将会被首先执行，然后 `dependency:copy-dependencies` **goal **会被执行，最终 `package`  **phase **被执行。

> **lifecycle：**生命周期，这是`maven`最高级别的的控制单元，它是一系列的`phase`组成，也就是说，一个生命周期，就是一个大任务的总称，不管它里面分成多少个子任务，反正就是运行一个`lifecycle`，就是交待了一个任务，运行完后，就得到了一个结果，中间的过程，是`phase`完成的，自己可以定义自己的`lifecycle`，包含自己想要的`phase`
>
> 常见的`lifecycle`有 _clean \| package ear \| pageage jar \| package war \| site_ 等等
>
> **phase**：可以理解为任务单元，`lifecycle`是总任务，`phase`就是总任务分出来的一个个子任务，但是这些子任务是被规格化的，它可以同时被多个`lifecycle`所包含，一个`lifecycle`可以包含任意个`phase`，`phase`的执行是按顺序的，一个`phase`可以绑定很多个`goal`，至少为一个，没有`goal`的`phase`是没有意义的
>
> **goal**：这是执行任务的最小单元，它可以绑定到任意个`phase`中，一个`phase`有一个或多个`goal`，`goal`也是按顺序执行的，一个`phase`被执行时，绑定到`phase`里的`goal`会按绑定的时间被顺序执行，不管`phase`己经绑定了多少个`goal`，你自己定义的`goal`都可以继续绑到`phase`中
>
> **mojo**：`lifecycle`与`phase`与`goal`都是概念上的东西，`mojo`才是做具体事情的，可以简单理解`mojo`为`goal`的实现类，它继承于`AbstractMojo`，有一个`execute`方法，`goal`等的定义都是通过在`mojo`里定义一些注释的 anotation 来实现的，`maven`会在打包时，自动根据这些 anotation 生成一些 xml 文件，放在 plugin 的 jar 包里

## Clean 生命周期 {#6c87af6752f6ca0409e280bbc692063f}

当我们执行`mvn post-clean`命令时，Maven 调用 `clean` 生命周期，它包含以下 **phase **。

* pre-clean
* clean
* post-clean

Maven 的 `clean`  **goal **（`clean:clean`）绑定到了 `clean` 生命周期的 `clean`  **phase **。它的 `clean:clean`  **goal **通过删除构建目录删除了构建输出。所以当 `mvn clean` 命令执行时，Maven 删除了构建目录。

我们可以通过在上面的 `clean` 生命周期的任何 **phase **定义 **goal **来修改这部分的操作行为。

在下面的例子中，我们将 `maven-antrun-plugin:run`  **goal **添加到 `pre-clean`、`clean` 和 `post-clean`  **phase **中。这样我们可以在 `clean` 生命周期的各个 **phase **显示文本信息。

我们已经在`C:\MVN\project`目录下创建了一个`pom.xml`文件。

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
   http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>com.companyname.projectgroup</groupId>
<artifactId>project</artifactId>
<version>1.0</version>
<build>
<plugins>
   <plugin>
   <groupId>org.apache.maven.plugins</groupId>
   <artifactId>maven-antrun-plugin</artifactId>
   <version>1.1</version>
   <executions>
      <execution>
         <id>id.pre-clean</id>
         <phase>pre-clean</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>pre-clean phase</echo>
            </tasks>
         </configuration>
      </execution>
      <execution>
         <id>id.clean</id>
         <phase>clean</phase>
         <goals>
          <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>clean phase</echo>
            </tasks>
         </configuration>
      </execution>
      <execution>
         <id>id.post-clean</id>
         <phase>post-clean</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>post-clean phase</echo>
            </tasks>
         </configuration>
      </execution>
   </executions>
   </plugin>
</plugins>
</build>
</project>
```

现在打开命令控制台，跳转到 pom.xml 所在目录，并执行下面的 mvn 命令。

```
C:\MVN\project>mvn post-clean
```

Maven 将会开始处理并显示 clean 生命周期的所有 **phase **。

```
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------
[INFO] Building Unnamed - com.companyname.projectgroup:project:jar:1.0
[INFO]    task-segment: [post-clean]
[INFO] ------------------------------------------------------------------
[INFO] [antrun:run {execution: id.pre-clean}]
[INFO] Executing tasks
     [echo] pre-clean phase
[INFO] Executed tasks
[INFO] [clean:clean {execution: default-clean}]
[INFO] [antrun:run {execution: id.clean}]
[INFO] Executing tasks
     [echo] clean phase
[INFO] Executed tasks
[INFO] [antrun:run {execution: id.post-clean}]
[INFO] Executing tasks
     [echo] post-clean phase
[INFO] Executed tasks
[INFO] ------------------------------------------------------------------
[INFO] BUILD SUCCESSFUL
[INFO] ------------------------------------------------------------------
[INFO] Total time: < 1 second
[INFO] Finished at: Sat Jul 07 13:38:59 IST 2012
[INFO] Final Memory: 4M/44M
[INFO] ------------------------------------------------------------------
```

你可以尝试修改 `mvn clean` 命令，来显示 `pre-clean` 和 `clean`，而在 `post-clean`  **phase **不执行任何操作。

## Default \(or Build\) 生命周期 {#34365a1a303b50007e2e48d9088c6b04}

这是 Maven 的主要生命周期，被用于构建应用。包括下面的 23 个 **phase **。

| 生命周期阶段（**phase**） | 描述 |
| :--- | :--- |
| validate | 检查工程配置是否正确，完成构建过程的所有必要信息是否能够获取到。 |
| initialize | 初始化构建状态，例如设置属性。 |
| generate-sources | 生成编译阶段需要包含的任何源码文件。 |
| process-sources | 处理源代码，例如，过滤任何值（filter any value）。 |
| generate-resources | 生成工程包中需要包含的资源文件。 |
| process-resources | 拷贝和处理资源文件到目的目录中，为打包阶段做准备。 |
| compile | 编译工程源码。 |
| process-classes | 处理编译生成的文件，例如 Java Class 字节码的加强和优化。 |
| generate-test-sources | 生成编译阶段需要包含的任何测试源代码。 |
| process-test-sources | 处理测试源代码，例如，过滤任何值（filter any values\)。 |
| test-compile | 编译测试源代码到测试目的目录。 |
| process-test-classes | 处理测试代码文件编译后生成的文件。 |
| test | 使用适当的单元测试框架（例如JUnit）运行测试。 |
| prepare-package | 在真正打包之前，为准备打包执行任何必要的操作。 |
| package | 获取编译后的代码，并按照可发布的格式进行打包，例如 JAR、WAR 或者 EAR 文件。 |
| pre-integration-test | 在集成测试执行之前，执行所需的操作。例如，设置所需的环境变量。 |
| integration-test | 处理和部署必须的工程包到集成测试能够运行的环境中。 |
| post-integration-test | 在集成测试被执行后执行必要的操作。例如，清理环境。 |
| verify | 运行检查操作来验证工程包是有效的，并满足质量要求。 |
| install | 安装工程包到本地仓库中，该仓库可以作为本地其他工程的依赖。 |
| deploy | 拷贝最终的工程包到远程仓库中，以共享给其他开发人员和工程。 |

有一些与 Maven 生命周期相关的重要概念需要说明：

* 当一个 **phase **通过 Maven 命令调用时，例如 `mvn compile`，只有**该阶段之前以及包括该阶段在内的所有阶段会被执行**。

* 不同的 Maven  **goal **将根据打包的类型（JAR / WAR / EAR），被绑定到不同的 Maven 生命周期 **phase **。

在下面的例子中，我们将 `maven-antrun-plugin:run`  **goal **添加到 Build 生命周期的一部分 **phase **中。这样我们可以显示生命周期的文本信息。

我们已经更新了 `C:\MVN\project` 目录下的 `pom.xml` 文件。

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
  http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>com.companyname.projectgroup</groupId>
<artifactId>project</artifactId>
<version>1.0</version>
<build>
<plugins>
<plugin>
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-antrun-plugin</artifactId>
<version>1.1</version>
<executions>
   <execution>
      <id>id.validate</id>
      <phase>validate</phase>
      <goals>
         <goal>run</goal>
      </goals>
      <configuration>
         <tasks>
            <echo>validate phase</echo>
         </tasks>
      </configuration>
   </execution>
   <execution>
      <id>id.compile</id>
      <phase>compile</phase>
      <goals>
         <goal>run</goal>
      </goals>
      <configuration>
         <tasks>
            <echo>compile phase</echo>
         </tasks>
      </configuration>
   </execution>
   <execution>
      <id>id.test</id>
      <phase>test</phase>
      <goals>
         <goal>run</goal>
      </goals>
      <configuration>
         <tasks>
            <echo>test phase</echo>
         </tasks>
      </configuration>
   </execution>
   <execution>
         <id>id.package</id>
         <phase>package</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
         <tasks>
            <echo>package phase</echo>
         </tasks>
      </configuration>
   </execution>
   <execution>
      <id>id.deploy</id>
      <phase>deploy</phase>
      <goals>
         <goal>run</goal>
      </goals>
      <configuration>
      <tasks>
         <echo>deploy phase</echo>
      </tasks>
      </configuration>
   </execution>
</executions>
</plugin>
</plugins>
</build>
</project>
```

现在打开命令控制台，跳转到 pom.xml 所在目录，并执行以下 mvn 命令。

```
C:\MVN\project>mvn compile
```

Maven 将会开始处理并显示直到 compile **phase **的构建生命周期的各个 **phase **。

```
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------
[INFO] Building Unnamed - com.companyname.projectgroup:project:jar:1.0
[INFO]    task-segment: [compile]
[INFO] ------------------------------------------------------------------
[INFO] [antrun:run {execution: id.validate}]
[INFO] Executing tasks
     [echo] validate phase
[INFO] Executed tasks
[INFO] [resources:resources {execution: default-resources}]
[WARNING] Using platform encoding (Cp1252 actually) to copy filtered resources,
i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory C:\MVN\project\src\main\resources
[INFO] [compiler:compile {execution: default-compile}]
[INFO] Nothing to compile - all classes are up to date
[INFO] [antrun:run {execution: id.compile}]
[INFO] Executing tasks
     [echo] compile phase
[INFO] Executed tasks
[INFO] ------------------------------------------------------------------
[INFO] BUILD SUCCESSFUL
[INFO] ------------------------------------------------------------------
[INFO] Total time: 2 seconds
[INFO] Finished at: Sat Jul 07 20:18:25 IST 2012
[INFO] Final Memory: 7M/64M
[INFO] ------------------------------------------------------------------
```

## Site 生命周期 {#386edab78b01321bd35ba799b5af8474}

Maven Site 插件一般用来创建新的报告文档、部署站点等。

阶段（**phase**）：

* pre-site
* site
* post-site
* site-deploy

在下面的例子中，我们将 `maven-antrun-plugin:run`  **goal **添加到 Site 生命周期的所有 **phase **中。这样我们可以显示生命周期的所有文本信息。

我们已经更新了 `C:\MVN\project` 目录下的 `pom.xml` 文件。

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
  http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>com.companyname.projectgroup</groupId>
<artifactId>project</artifactId>
<version>1.0</version>
<build>
<plugins>
<plugin>
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-antrun-plugin</artifactId>
<version>1.1</version>
   <executions>
      <execution>
         <id>id.pre-site</id>
         <phase>pre-site</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>pre-site phase</echo>
            </tasks>
         </configuration>
      </execution>
      <execution>
         <id>id.site</id>
         <phase>site</phase>
         <goals>
         <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>site phase</echo>
            </tasks>
         </configuration>
      </execution>
      <execution>
         <id>id.post-site</id>
         <phase>post-site</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>post-site phase</echo>
            </tasks>
         </configuration>
      </execution>
      <execution>
         <id>id.site-deploy</id>
         <phase>site-deploy</phase>
         <goals>
            <goal>run</goal>
         </goals>
         <configuration>
            <tasks>
               <echo>site-deploy phase</echo>
            </tasks>
         </configuration>
      </execution>
   </executions>
</plugin>
</plugins>
</build>
</project>
```

现在打开命令控制台，跳转到 pom.xml 所在目录，并执行以下 mvn 命令。

```
C:\MVN\project>mvn site
```

Maven 将会开始处理并显示直到 site  **phase **的构建生命周期的各个 **phase **。

    [INFO] Scanning for projects...
    [INFO] ------------------------------------------------------------------
    [INFO] Building Unnamed - com.companyname.projectgroup:project:jar:1.0
    [INFO]    task-segment: [site]
    [INFO] ------------------------------------------------------------------
    [INFO] [antrun:run {execution: id.pre-site}]
    [INFO] Executing tasks
         [echo] pre-site phase
    [INFO] Executed tasks
    [INFO] [site:site {execution: default-site}]
    [INFO] Generating "About" report.
    [INFO] Generating "Issue Tracking" report.
    [INFO] Generating "Project Team" report.
    [INFO] Generating "Dependencies" report.
    [INFO] Generating "Project Plugins" report.
    [INFO] Generating "Continuous Integration" report.
    [INFO] Generating "Source Repository" report.
    [INFO] Generating "Project License" report.
    [INFO] Generating "Mailing Lists" report.
    [INFO] Generating "Plugin Management" report.
    [INFO] Generating "Project Summary" report.
    [INFO] [antrun:run {execution: id.site}]
    [INFO] Executing tasks
         [echo] site phase
    [INFO] Executed tasks
    [INFO] ------------------------------------------------------------------
    [INFO] BUILD SUCCESSFUL
    [INFO] ------------------------------------------------------------------
    [INFO] Total time: 3 seconds
    [INFO] Finished at: Sat Jul 07 15:25:10 IST 2012
    [INFO] Final Memory: 24M/149M
    [INFO] ------------------------------------------------------------------```

# Maven的插件

其实在刚才介绍生命周期中已经提到了可以在命令行的`mvn`命令后直接指定插件目标，之所以Maven支持这种方式是因为有些任务不适合绑定到生命周期上。在命令行调用插件的格式如下 ：

`mvn groupId:artifactId:version:goal`

其中`groupId`、`artifactId`、`version`共同表示了插件的坐标；`goal`则表示插件目标的方法。

但我们看到很多执行插件目标的格式与之并不相符，例如文章开头的`mvn archetype:create`，`archetype`并不是`groupId`、`artifactId`或`version`而是插件的前缀，这就有了第二种调用插件的格式：

`mvn 前缀:goal`

Maven是如何解析插件的前缀的呢？实际是Maven是通过查询插件仓库的元数据才得知插件前缀对应插件的`groupId`、`artifactId`,而如果插件是Maven的核心插件则在超级POM中已经定义了插件的版本，如果不是核心插件，则默认取最新的release版本。

Maven的插件仓库默认是`http://repo1.maven.org/maven2/org/apache/maven/plugins/`和`http://repository.codehaus.org/org/codehaus/mojo/`，相应的查询插件仓库元数据时会默认使用`org.apache.maven.plugins`和`org.codehaus.mojo`两个`groupId`。但也可以通过配置`settings.xml`让Maven检查其他`groupId`上的插件仓库元数据，如：

```
<settings>    
    <pluginGroups>
        <pluginGroup>com.your.plugins</pluginGroup>
    </pluginGroups>
</settings>
```

这样配置后，Maven就不只检查`org/apache/maven/plugins/maven-metadata.xml`和`org/codehaus/mojo/maven-metadata.xml`，还会检查`com/your/plugins/maven-metadata.xml`。

