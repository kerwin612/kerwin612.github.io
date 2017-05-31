# org.codehaus.plexus.archiver.jar.Manifest.merge(org.codehaus.plexus.archiver

错误原因：
>java maven 项目导入 eclipse 时出现`org.codehaus.plexus.archiver.jar.Manifest.merge(org.codehaus.plexus.achiver.jar.Manifest)`错误。原因是，`m2eclipse-mavenarchiver` 通过反射方法调用 `mavenarchiver` 插件中的 `merge()` 方法，而该方法在 `mavenarchiver 2.4` 中已被移除，所以调用失败。  

解决方法：  
- 升级`m2eclipse-mavenarchiver`。升级地址：http://repo1.maven.org/maven2/.m2e/connectors/m2eclipse-mavenarchiver/0.17.0/N/LATEST/  
- In the mean time the workaround is to set the maven-jar-plugin version to 2.3.2.  

