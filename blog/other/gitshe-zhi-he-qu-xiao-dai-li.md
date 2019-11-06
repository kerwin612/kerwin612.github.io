#git 设置和取消代理  

**设置代理**   
`git config --global http.proxy socks5h://127.0.0.1:1080`  
**取消代理**   
`git config --global --unset http.proxy`  
***如果用的是`http`代理，将`socks5h`改为`http`即可***  

如果仅仅想为 github 设置代理，可以这样：  
```
#git config --global http.<domain>.proxy <proxy-addr>
git config --global http.https://github.com.proxy socks5h://127.0.0.1:1080
```  

**对于使用`git@`协议的，可以配置`socks5`代理**   
在`~/.ssh/config`文件后面添加几行(没有可以新建一个)   
```
Host github.com
User git
ProxyCommand nc -X 5 -x 127.0.0.1:1080 %h %p
```
`windows`使用：   
```
Host github.com
User git
ProxyCommand connect -S 127.0.0.1:1080 %h %p
```