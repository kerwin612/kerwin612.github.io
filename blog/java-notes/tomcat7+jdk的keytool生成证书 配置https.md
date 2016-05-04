# tomcat7+jdk的keytool生成证书 配置https


####生成keystore文件及导出证书

打开控制台：  
运行：
```bash
%JAVA_HOME%\bin\keytool -genkey -alias tomcat -keyalg RSA
```
按照要求一步步的输入信息，问你国家/地区代码的时候，输入cn。

输入密码的时候，这里使用：changeit

最后一步让你输入的时候，直接回车。

具体记录如下：
```cmd
C:\Users\Administrator>%JAVA_HOME%\bin\keytool -genkey -alias tomcat -keyalg RSA

输入密钥库口令:
再次输入新口令:
您的名字与姓氏是什么?
 [Unknown]: tuhao
您的组织单位名称是什么?
 [Unknown]: tuhaojia
您的组织名称是什么?
 [Unknown]: fnic
您所在的城市或区域名称是什么?
 [Unknown]: didu
您所在的省/市/自治区名称是什么?
 [Unknown]: didu
该单位的双字母国家/地区代码是什么?
 [Unknown]: cn
CN=tuhao, OU=tuhaojia, O=fnic, L=didu, ST=didu, C=cn是否正确?
 [否]: y

输入 <tomcat> 的密钥口令
(如果和密钥库口令相同, 按回车)
```
完毕后会在当前目录下，会产生一个：.keystore文件，将它拷贝到tomcat的bin目录下。

从控制台进入tomcat的bin目录，本机环境是：D:\Tomcat7\bin>

####导出证书文件：

```cmd
D:\Tomcat7\bin>keytool -selfcert -alias tomcat -keystore .keystore
输入密钥库口令:（此处为上面生成证书时输入的changeit）
D:\Tomcat7\bin>keytool -export -alias tomcat -keystore .keystore -storepass changeit -rfc -file tomcat.cer
```

存储在文件 <tomcat.cer> 中的证书

此时会在D:\Tomcat7\bin>下生成tomcat.cer证书文件。将该文件发给使用者，让他们安装该证书，并将证书安装在“受信任的根证书颁发机构”区域中。具体的操作步骤可以参照铁道部12306.cn网站证书的安装步骤。它们是一样一样一样的。

####配置tomcat

打开$CATALINA_BASE/conf/server.xml 找到“SSL HTTP/1.1 Connector” 那一块，取消注释并将它改成：
```xml
<Connector port="443" protocol="HTTP/1.1" SSLEnabled="true"

maxThreads="150" scheme="https" secure="true"
	keystoreFile="bin/.keystore" keystorePass="changeit" 
 clientAuth="false" sslProtocol="TLS" />
```
请注意，这里我已经将tomcat的端口改成了80，相应的，https的端口我也改成了443（即默认的https端口）。

修改windows机器的host文件，增加一行(我的机器的ip是192.168.68.75)：

192.168.68.75 tuhao

 接下来重启tomcat，用https://tuhao/访问网站验证一下就行了。


**总结：**
***生成证书的时候，“您的名字与姓氏是什么”  一定要注意输入你的ip、机器名、域名，总之，你希望以后通过https://xx来访问你的网站的话，此处就要填写xx。否则，会有证书不受信的提示。***


