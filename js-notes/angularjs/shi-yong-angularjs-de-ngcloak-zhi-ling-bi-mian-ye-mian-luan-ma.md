# 使用Angularjs的ng-cloak指令避免页面乱码

在使用 Anguarjs 进行 web开发 或者进行 SPA（single page application）开发时，往往会遇到下面这样的问题。

刷新页面时，页面会出现一些乱码，这里的乱码具体是指 `{{expression}}` 或者 `{{expression | filter}}` 这种形式的表达式乱码，然后这些乱码又快速的消失了，然后页面就正常了。这个问题的原因是，在一些现代浏览器，比如 Chrome，Firefox 等中尤为严重。当然还跟环境的网络速度有关。

出现这个问题的根本原因是，JavaScript 操作DOM 都是在DOM加载完成（DOM Ready）之后的才进行的。换句话说， Angularjs 只会在DOM Ready之后才回去解析 html模版 以及 Angularjs 的 directive，在这之前 html模版 中的内容会被原封不动的展示在页面，这时候就会出现所谓的乱码问题。

那么我们如何解决这个问题呢？

Angularjs 官方针对这个问题提供了原生的解决方案，就是我们今天要说的主角 `ng-cloak` 指令。

我们先来看一下 Angularjs 的源码中对这个 `ng-cloak` 是如何实现的。

Angularjs 将 `ng-cloak` 实现为 `directive`，其代码如下

```javascript
!angular.$$csp()
&& angular
    .element(document)
    .find('head')
    .prepend('<style type="text/css">' +
        '@charset "UTF-8";' +
        '[ng\\:cloak],[ng-cloak],[data-ng-cloak],[x-ng-cloak],.ng-cloak,.x-ng-cloak,.ng-hide{display:none !important;}' +
        'ng\\:form{display:block;}' +
        '.ng-animate-block-transitions{transition:0s all!important;-webkit-transition:0s all!important;}' +
        </style>');
```

大家不要对这一坨代码感到畏惧，其实它做的事很简单，就是在 html 中的 head标签 中插入一段内联的 css样式。其中部分的代码是这样的

```css
[ng\\:cloak],
[ng-cloak],
[data-ng-cloak],
[x-ng-cloak],
.ng-cloak,
.x-ng-cloak,
.ng-hide {
    display:none !important;
}
```

很显然，Angularjs 对 `ng-cloak` 相关的元素设置了 `display: none !important` 这样一个属性，目的就是隐藏相关元素。这样在在DOM还没有Ready的时候，将相关元素隐藏起来，这样页面就不会出现乱码了。

当DOM Ready的时候，Angularjs 开始解析指令。我们来看一下 `ng-cloak` 这个指令都做了哪些事情

```javascript
var ngCloakDirective = ngDirective({
    compile: function(element, attr) {
        attr.$set('ngCloak', undefined);
        element.removeClass('ng-cloak');
    }
});
```

可见，当 Angularjs 开始解析 `ng-cloak` 指令的时候，又会把这个样式给去除掉。这样页面又显示了。

通过以上分析，我们知道了使用 `ng-cloak` 指令来避免页面出现乱码的原理，其实通过先隐藏后显示来规避了DOM尚未Ready这段时间的真空期。

理论是美好的，但是现实往往会给我一个响亮的耳光。

在实际使用的过程中，我们要想使上面的过程完美表现，就必须要先在 head标签 中先引入 Angularjs 的源码，而不能在页面的最后引入 Angularjs 文件。

因为后者会造成这样一种情况：在 Angularjs 文件还没引入时，意味着还没给 `ng-cloak` 相关元素做隐藏处理，页面就已经展示了，这是页面仍然会出现乱码。

但是一般性的原则告诉我们，应该把 css文件 放在头部，把 js文件 放在尾部。那么我们如何解决这个矛盾呢？

解决方案是，我们手动在 head 中将 `ng-cloak` 相关的元素设置为隐藏，即添加如下的代码

```markup
<head>
    <style>
        [ng:cloak],
        [ng-cloak],
        [data-ng-cloak],
        [x-ng-cloak],
        .ng-cloak,
        .x-ng-cloak {
            display:none !important;
        }
    </style>
</head>
```

或者将这一段代码放在我们在 head 中加载的 css文件 中，这样就可以确保页面加载的时候，不管它有没有DOM Ready，`ng-cloak` 相关元素肯定是隐藏的。

如果你发现在 body 上加了 `ng-cloak`，但是仍然不起作用，那么原因应该就是上面所描述的，这时候你就需要在 head中 添加隐藏代码或者在引入的 css文件 中添加相关代码了。

最后提一点，如果中的表达式仅仅是展示一些文本内容，我们可以使用 `ng-bind` 这个指令来实现。

本文链接：[http://blog.gejiawen.com/2014/12/28/usage-for-angularjs-ng-cloak/](http://blog.gejiawen.com/2014/12/28/usage-for-angularjs-ng-cloak/)

