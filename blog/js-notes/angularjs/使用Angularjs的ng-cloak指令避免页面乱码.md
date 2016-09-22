# 使用Angularjs的ng-cloak指令避免页面乱码

在使用 Anguarjs 进行 web开发 或者进行 SPA（single page application）开发时，往往会遇到下面这样的问题。  
  
刷新页面时，页面会出现一些乱码，这里的乱码具体是指 `{{expression}}` 或者 `{{expression | filter}}` 这种形式的表达式乱码，然后这些乱码又快速的消失了，然后页面就正常了。这个问题的原因是，在一些现代浏览器，比如 Chrome，Firefox 等中尤为严重。当然还跟环境的网络速度有关。  
  
出现这个问题的根本原因是，JavaScript 操作DOM 都是在DOM加载完成（DOM Ready）之后的才进行的。换句话说， Angularjs 只会在DOM Ready之后才回去解析 html模版 以及 Angularjs 的 directive，在这之前 html模版 中的内容会被原封不动的展示在页面，这时候就会出现所谓的乱码问题。  
  
那么我们如何解决这个问题呢？  
  
Angularjs 官方针对这个问题提供了原生的解决方案，就是我们今天要说的主角 `ng-cloak` 指令。  
  
我们先来看一下 Angularjs 的源码中对这个 `ng-cloak` 是如何实现的。  
  
Angularjs 将 `ng-cloak` 实现为 `directive`，其代码如下  
