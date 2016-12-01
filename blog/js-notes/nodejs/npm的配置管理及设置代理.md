# npm的配置管理及设置代理

`npm`全称为`Node Packaged Modules`。它是一个用于管理基于`node.js`编写的`package`的命令行工具。其本身就是基于`node.js`写的,这有点像`gem`与`ruby`的关系。  

在我们的项目中，需要使用一些基于`node.js`的`js库`文件，就需要`npm`对这些依赖库进行方便的管理。由于我们的开发环境由于安全因素在访问一些网站时需要使用代理，其中就包括`npm`的`repositories`网站，所以就需要修改`npm`的配置来加入代理。

下面简要介绍下`npm`的配置以及如何设置代理。  

-----

###`npm`获取配置有6种方式，优先级由高到底。  
1. 命令行参数。 `--proxy http://server:port`即将**proxy**的值设为***http://server:port***。

2. 环境变量。 以`npm_config_`为前缀的环境变量将会被认为是`npm`的配置属性。如设置**proxy**可以加入这样的环境变量`npm_config_proxy=http://server:port`。

3. 用户配置文件。可以通过`npm config get userconfig`查看文件路径。如果是mac系统的话默认路径就是`$HOME/.npmrc`。

4. 全局配置文件。可以通过`npm config get globalconfig`查看文件路径。mac系统的默认路径是`/usr/local/etc/npmrc`。

5. 内置配置文件。安装`npm`的目录下的**npmrc**文件。

6. 默认配置。 `npm`本身有默认配置参数，如果以上5条都没设置，则`npm`会使用默认配置参数。  

-----

###针对npm配置的命令行操作  
```shell
   npm config set <key> <value> [--global]
   npm config get <key>
   npm config delete <key>
   npm config list
   npm config edit
   npm get <key>
   npm set <key> <value> [--global]
```
在设置配置属性时属性值默认是被存储于用户配置文件中，如果加上`--global`，则被存储在全局配置文件中。  

如果要查看`npm`的所有配置属性（包括默认配置），可以使用`npm config ls -l`。  

如果要查看`npm`的各种配置的含义，可以使用`npm help config`。  

-----

###为npm设置代理  
```shell
$ npm config set proxy http://server:port
$ npm config set https-proxy http://server:port
```
如果代理需要认证的话可以这样来设置。  
```shell
$ npm config set proxy http://username:password@server:port
$ npm config set https-proxy http://username:pawword@server:port
```
如果代理不支持https的话需要修改npm存放package的网站地址。  
```shell
$ npm config set registry "http://registry.npmjs.org/"
```

转：http://www.cnblogs.com/huang0925