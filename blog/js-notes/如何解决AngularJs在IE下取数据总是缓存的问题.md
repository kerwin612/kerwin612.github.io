# 如何解决AngularJs在IE下取数据总是缓存的问题

如果用AngularJs在IE下发出GET请求从后台服务取完Json数据再绑定到页面上显示的话，你可能会发现就算数据更新了，IE还是会显示原来的结果。实际上这时候IE的确是缓存了hashtag，没有再次去做Http GET请求最新的数据。   

最直接的办法是在后台撸掉OutputCache，但这种做法并不推荐，需要改每一处被Angular调用的地方，代价太大。这种问题应该在前端解决最好。研究了一会儿总结了最有效的解决方法，并不需要改后台代码了。     
 
在你的app config里撸一个$httpProvider进去，比如像我这样，和路由可以配在一起，当然分开配也没问题。
```js
var config = ["$routeProvider", "$httpProvider", function ($routeProvider, $httpProvider) {
        // Initialize get if not there
        if (!$httpProvider.defaults.headers.get) {
            $httpProvider.defaults.headers.get = {};
        }
 
        // Enables Request.IsAjaxRequest() in ASP.NET MVC
        $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
 
        // Disable IE ajax request caching
        $httpProvider.defaults.headers.get['Cache-Control'] = 'no-cache';
        $httpProvider.defaults.headers.get['Pragma'] = 'no-cache';
 
        $routeProvider.when("/", { templateUrl: "Manage/dashboard/index.cshtml" })
                      .when("/dashboard", { templateUrl: "Manage/dashboard/index.cshtml" })
                      .when("/dashboard/serverinfo", { templateUrl: "Manage/dashboard/serverinfo.cshtml" })
                      .when("/dashboard/emaillogs", { templateUrl: "Manage/dashboard/emaillogs.cshtml" })
					  // other code....
                      .otherwise({ redirectTo: "/" });
    }];
 
app.config(config);
```
最关键的就是最后的禁用IE对ajax的缓存   
```js
$httpProvider.defaults.headers.get['Cache-Control'] = 'no-cache';
$httpProvider.defaults.headers.get['Pragma'] = 'no-cache';
```
如果你想这样写，是会爆的：   
```js
$httpProvider.defaults.headers.get['If-Modified-Since'] = '0';
```
这样会导致include指令加载的partial view撸不出来，所以不要作死了。。。    

而实际上我这样设置并没有卵用，我是在后端的统一过滤器里面对response加了这两个头，才得以解决问题的。
```java
response.addHeader("Cache-Control", "no-cache");
response.addHeader("Pragma", "no-cache");
```