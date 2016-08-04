# nginx使用ssl模块配置HTTPS支持

默认情况下ssl模块并未被安装，如果要使用该模块则需要在编译时指定–with-http_ssl_module参数，安装模块依赖于OpenSSL库和一些引用文件，通常这些文件并不在同一个软件包中。通常这个文件名类似libssl-dev。  
  
###生成证书  
  
可以通过以下步骤生成一个简单的证书：
首先，进入你想创建证书和私钥的目录，例如：  
1.`cd /usr/local/nginx/conf`  
  
创建服务器私钥，命令会让你输入一个口令：
1.`openssl genrsa -des3 -out server.key 1024`    
  
创建签名请求的证书（CSR）：
1.`openssl req -new -key server.key -out server.csr`    
   
在加载SSL支持的Nginx并使用上述私钥时除去必须的口令：
1.`cp server.key server.key.org`  
2.`openssl rsa -in server.key.org -out server.key`  
  
###配置nginx  
  
最后标记证书使用上述私钥和CSR：    
1.`openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`  
  
修改Nginx配置文件，让其包含新标记的证书和私钥：  
```json
server {
    server_name YOUR_DOMAINNAME_HERE;
    listen 443;
    ssl on;
    ssl_certificate /usr/local/nginx/conf/server.crt;
    ssl_certificate_key /usr/local/nginx/conf/server.key;
}
```
  
重启nginx。  
这样就可以通过以下方式访问：   
https://YOUR_DOMAINNAME_HERE  
  
另外还可以加入如下代码实现80端口重定向到443  
```json
server {
	listen 80;
	server_name ww.centos.bz;
	rewrite ^(.*) https://$server_name$1 permanent;
}
```
  
转载请注明文章来源：http://www.centos.bz/2011/12/nginx-ssl-https-support/
