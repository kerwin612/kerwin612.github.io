# maven plugin的execution出错

`Plugin execution not covered by lifecycle configuration: org.apache.maven.plugins:maven-dependency-plugin:2.7:copy...`  

解决办法：
```xml
<build>
    <pluginManagement>
        <plugins>
            <plugin>
                <groupId>org.eclipse.m2e</groupId>
                <artifactId>lifecycle-mapping</artifactId>
                <version>1.0.0</version>
                <configuration>
                    <lifecycleMappingMetadata>
                        <pluginExecutions>
                            <pluginExecution>
                                <pluginExecutionFilter>
                                    <groupId>org.apache.maven.plugins</groupId>
                                    <artifactId>maven-resources-plugin</artifactId>
                                    <versionRange>[2.0,)</versionRange>
                                    <goals>
                                        <goal>resources</goal>
                                        <goal>testResources</goal>
                                    </goals>
                                </pluginExecutionFilter>
                                <action>
                                    <ignore />
                                </action>
                            </pluginExecution>
                        </pluginExecutions>
                    </lifecycleMappingMetadata>
                </configuration>
            </plugin>
        </plugins>
    </pluginManagement>
</build>
```
可这里的maven插件与我的不一样，又没讲清楚具体在哪里改动了。继续看 [](http://stackoverflow.com/questions/6352208/how-to-solve-plugin-execution-not-covered-by-lifecycle-configuration-for-sprin) 这里貌似罗嗦了这个错误的原因:  
```
To solve some long-standing issues, m2e 1.0 requires explicit instructions what to do with all Maven plugins bound to "interesting" phases (see M2E interesting lifecycle phases) of project build lifecycle. We call these instructions "project build lifecycle mapping" or simply "lifecycle mapping" because they define how m2e maps information from project pom.xml file to Eclipse workspace project configuration and behaviour during Eclipse workspace build.

Project build lifecycle mapping configuration can be specified in project pom.xml, contributed by Eclipse plugins and there is also default configuration for some commonly used Maven plugins shipped with m2e. We call these "lifecycle mapping metadata sources". m2e will create error marker like below for all plugin executions that do not have lifecycle mapping in any of the mapping metadata sources.

Plugin execution not covered by lifecycle configuration:
org.apache.maven.plugins:maven-antrun-plugin:1.3:run

   (execution: generate-sources-input, phase: generate-sources)

m2e matches plugin executions to actions using combination of plugin groupId, artifactId, version range and goal. There are three basic actions that m2e can be instructed to do with a plugin execution --ignore, execute and delegate to a project configurator.
```  

最终是这里提到了怎么解决：`In my case of a similar problem, instead of using Andrew's suggestion for the fix, it worked simply after I introduced <pluginManagement> tag to the pom.xml in question. Looks like that error is due to a missing <pluginManagement> tag. So, in order to avoid the exceptions in Eclipse, looks like one needs to simply enclose all the plugin tags inside a <pluginManagement> tag, like so:`  
```xml
<build>
    <pluginManagement>
        <plugins>
            <plugin> ... </plugin>
            <plugin> ... </plugin>
                  ....
        </plugins>
    </pluginManagement>
</build>
我之前的结构是
<build>
        <plugins>
            <plugin> ... </plugin>
            <plugin> ... </plugin>
                  ....
        </plugins>
</build>
```
加上**pluginManagement**包裹起来后就没有这个错误了。

好吧，这个解决方法领导不满意，pluginManagement的作用是作为公用的插件配置项，给子项目共用的。这个项目没有子项目，这样处理不是很合理，领导最终找到另一种配置方式。去掉plugins标签外的pluginManagement包裹，在plugins的上层加一个pluginManagement，与原先的plugin平行，针对出问题的插件增加单独的配置，修改后的结构如下：
```xml
<build>
    <pluginManagement>
        <plugins>
            <plugin> ... </plugin>
        </plugins>
    </pluginManagement> 
       <plugins>
            <plugin> ... </plugin>
            <plugin> ... </plugin>
                  ....
        </plugins>
</build>
```
pluginManagement内的详细配置如下：
```xml
<pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.eclipse.m2e</groupId>
                    <artifactId>lifecycle-mapping</artifactId>
                    <version>1.0.0</version>
                    <configuration>
                        <lifecycleMappingMetadata>
                            <pluginExecutions>
                                <pluginExecution>
                                    <pluginExecutionFilter>
                                        <groupId>org.apache.maven.plugins</groupId>
                                        <artifactId>maven-dependency-plugin</artifactId>
                                        <versionRange>[0.0.0,)</versionRange>
                                        <goals>
                                            <goal>copy</goal>
                                        </goals>
                                    </pluginExecutionFilter>
                                    <action>
                                        <ignore />
                                    </action>
                                </pluginExecution>
                            </pluginExecutions>
                        </lifecycleMappingMetadata>
                    </configuration>
                </plugin>
            </plugins>
        </pluginManagement>
```

好吧，问题算是合理地解决了。可有人比额领导还纠结，说这个配置不该放在pom文件里，应该是ide来处理这个配置，就有了这个：[](http://liwenqiu.me/blog/2012/12/19/maven-lifecycle-mapping-not-converted/)
在`eclipse->preference->maven->lifecycle mappings`中，myeclipse的话`Maven4MyEclipse->Lifecycle mappings`，向上面所示进行配置，保存更新project。未试过eclipse下情况如何，MyEclipse默认配置路径是没有lifecycle-mapping-metadata.xml这个文件的，只有<项目名>.lifecyclemapping一系列这样的文件，但提供一个按钮“Open workspace lifecycle mappings metadata”里进行编辑。或者Change mapping file location。
      好吧，这样也许是最应该的处理的方式，但让每个开发人员都改下ide配置，还不如直接改下pom.xml文件的配置，最终采用了修改pom.xml文件的方式。
      好吧，最终还是将出错原因和解决思路抄一下：

>基于maven的项目，使用各种maven plugin来完成开发中的各种工作，例如编译代码，打包，部署等等… 每个plugin包含许多的goal，用来做特定的事情。典型的基于java的maven项目就有 clean compile test package deploy等goal要执行。除了这些比较常见的goal之外，项目中还可以使用大量的第三方的plugin，甚至自己动手开发的plugin。

>随之而来的问题是，在eclipse中编辑maven项目的时候，eclipse并不知道这些goal要做什么，通用的goal还好说，特殊用途的goal就没有办法了。所以m2eclipse这个集成maven到eclipse的plugin就提供了开发extra的能力，eclipse利用这些extra来完成本来在maven plugin要干的活。

>如果eclipse没有办法知道某个goal要干什么，那么通常就会看到如下的错误信息：`Plugin execution not covered by lifecycle configuration: org.apache.maven.plugins:maven-dependency-plugin:2.6:copy (execution: default, phase: validate)`

由于我个人更倾向于在命令行下让maven干活，而eclipse更多的只是充当编辑器的角色，所以我要的只是让eclipse忽略掉这些goal就好了。

参考这里[](http://wiki.eclipse.org/M2E_plugin_execution_not_covered)之后，要做的就是告诉eclipse要忽略的goal.