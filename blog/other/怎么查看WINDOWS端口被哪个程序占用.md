# 怎么查看WINDOWS端口被哪个程序占用

DOS下命令：  
`netstat -a -n`  各个端口占用  
`netstat -ano`   各个端口占用和进程PID  
  
  

假如我们需要确定谁占用了我们的80端口：  

在windows命令行窗口下执行：
```CMD
C:\>netstat -aon|findstr "80"
TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       1648
TCP    0.0.0.0:81             0.0.0.0:0              LISTENING       1716
```
看到了吗，端口被进程号为1648的进程占用，继续执行下面命令：
```CMD
C:\>tasklist|findstr "1648"
Apache.exe                   1648 Console                 0      6,496 K
```
很显然Apache占用了你的端口。