# MavenActionUtil.getMavenProject\(e.getDataContext\(\)\) is Null when developing a intellij plugin

Please make sure that you've added the jars of the Maven plugin to the classpath of your IntelliJ IDEA SDK and not as a separate library. Doing the latter will cause two copies of the Maven plugin classes to be loaded, which will lead to the problem that you're describing. I guess that if you want to get "MavenProject" or other "Maven" information in plugins, you have to do two things. - add "maven.jar " and "maven-server-api.jar" to your Intellij IDEA SDK, - add depends "org.jetbrains.idea.maven" to your plugin.xml.

