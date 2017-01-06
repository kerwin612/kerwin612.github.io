#JDK中文字体在Linux操作系统的设置方案

JDK中文字体的设置为什么重要呢？我们经常会发现在Linux下，java应用程序的中文会变成一个一个的“口”字，这样会给我们的使用带来很多的困扰。但是我们又不愿意放弃Linux和java的便捷。

怎么来解决JDK中文问题呢？

其实，要解决JDK中文问题也挺简单。

首先来说说产生这个问题的原因。java程序启动的时候会去在`$JAVA_HOME/jre/lib/fonts`目录下寻找相应的字体来显示。由于**JDK默认没有中文字体**，所以我们需要手工的来设置一下，让java应用程序能够找到相应的中文字体。这样就能够解决问题了。

现在思路已经很清晰了，那我们就来着手解决问题吧。

JDK中文处理办法基本步骤如下：

1. cd $JAVA_HOME/jre/lib/fonts  
2. mkdir fallback  
3. cp xxx.ttf fallback #xxx.ttf代表你想要的中文字体文件  
4. cd fallback  
5. mkfontscale   
        如果没有此命令就先执行（`apt-get install xfonts-utils`）  
        如果出现 “Couldn't get family name for *****.**” 就先执行（`rm -f *****.**`）  
6. mkfontdir  
7. fc-cache   
        如果没有此命令就先执行（`apt-get install fontconfig`）

其实，我们可以一条命令解决来JDK中文问题。将Linux系统的字体目录作为JDK下面的一个字体目录连接。
```shell
ln -s $FONTS_PATH/FONT_DIR $JAVA_HOME/jre/lib/fonts/fallback 
```
你在打开你的java应用程序就会看到久违的中文了。

JDK中文在Linux操作系统的设置就介绍到这里，那么现在你是不是对于JDK中文处理办法有了自己的认识呢？