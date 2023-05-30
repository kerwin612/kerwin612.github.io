# AngularJS 中的一些坑

最近几个月频繁的跟AngularJS打交道，对于web应用开发来说Angular真的是一个神奇的框架，但是没有东西是完美的，在这篇文章里我会把我的感悟罗列出来，希望可以产生共鸣（前提是你对Angular已经有所了解）。

**UI的闪烁**  
Angular的自动数据绑定功能是亮点，然而，他的另一面是：在Angular初始化之前，页面中可能会给用户呈现出没有解析的表达式。当DOM准备就绪，Angular计算并替换相应的值。这样就会导致出现一个丑陋的闪烁效果。  
![](data:image/png;base64,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)  
上述情形就是在Angular教程中渲染示例代码的样子：

```markup
<body ng-controller="PhoneListCtrl">
  <ul>
    <li ng-repeat="phone in phones">
      {{ phone.name }}
      <p>{{ phone.snippet }}</p>
    </li>
  </ul>
</body>
```

如果你做的是SPA\(Single Page Application\)，这个问题只会在第一次加载页面的时候出现，幸运的是，可以很容易杜绝这种情形发生: 放弃`{{ }}`表达式，改用ng-bind指令

```markup
<body ng-controller="PhoneListCtrl">
  <ul>
    <li ng-repeat="phone in phones">
      <span ng-bind="phone.name"></span>
      <p ng-bind="phone.snippet">Optional: visually pleasing placeholder</p>
    </li>
  </ul>
</body>
```

你需要一个tag来包含这个指令，所以我添加了一个 &lt;span&gt; 给phone name.

那么初始化的时候会发生什么呢，这个tag里的值会显示\(但是你可以选择设置空值\).然后，当Angular初始化并用表达式结果替换tag内部值，注意你不需要在 [ng-bind](http://docs.angularjs.org/api/ng.directive:ngBindTemplate) 内部添加大括号。更简洁了！如果你需要符合表达式，那就用 [ng-bind-template](http://docs.angularjs.org/api/ng.directive:ngBindTemplate) 吧， 如果用这个指令，为了区分字符串字面量和表达式，你需要使用大括号  
另外一种方法就是完全隐藏元素，甚至可以隐藏整个应用，直到Angular就绪。

Angular为此还提供了 [ng-cloak](http://docs.angularjs.org/api/ng.directive:ngCloak) 指令，工作原理就是在初始化阶段inject了css规则，或者你可以包含这个css 隐藏规则到你自己的stylesheet。Angular就绪后就会移除这个cloak样式，让我们的应用\(或者元素\)立刻渲染。

Angular并不依赖jQuery。事实上，Angular源码里包含了一个内嵌的轻量级的jquery: [jqLite](http://docs.angularjs.org/api/angular.element) . 当Angular检测到你的页面里有jQuery出现，他就会用这个jQuery而不再用jqLite，直接证据就是Angular里的元素抽象层。比如，在directive中访问你要应用到的元素。

```javascript
angular.module('jqdependency', [])
  .directive('failswithoutjquery', function() {
    return {
      restrict : 'A',
      link : function(scope, element, attrs) {
               element.hide(4000)
             }
    }
});
```

\(演示代码： [this plunkr](http://plunker.co/edit/aqeDikqd6O2QaqH3eaIq?p=preview) \)

但是这个元素jqLite还是jQuery元素呢？取决于，手册上这么写的：

> Angular 中所有的元素引用都会被 jQuery 或者 jqLite 包装；他们永远不是纯 DOM 引用

所以Angular如果没有检测到jQuery，那么就会使用jqLite元素，hide\(\)方法值能用于jQuery元素，所以说这个示例代码只能当检测到jQuery时才可以使用。如果你\(不小心\)修改了AngularJS和jQuery的出现顺序，这个代码就会失效！虽说没事挪脚本的顺序的事情不经常发生，但是在我开始模块化代码的时候确实给我造成了困扰。尤其是当你开始使用模块加载器\(比如 [RequireJS](http://requirejs.org/) \), 我的解决办法是在配置里显示的声明Angular确实依赖jQuery  
另外一种方法就是你不要通过Angular元素的包装来调用jQuery特定的方法，而是使用$\(element\).hide\(4000\)来表明自己的意图。这样依赖，即使修改了script加载顺序也没事。

**压缩**  
特别需要注意的是Angular应用压缩问题。否则错误信息比如 ‘Unknown provider:aProvider &lt;- a’ 会让你摸不到头脑。跟其他很多东西一样，这个错误在官方文档里也是无从查起的。简而言之，Angular依赖参数名来进行依赖注入。压缩器压根意识不到这个这跟Angular里普通的参数名有啥不同，尽可能的把脚本变短是他们职责。咋办？用“友好压缩法”来进行方法注入。看这里：

```javascript
module.service('myservice', function($http, $q) {
// This breaks when minified
});
to this:
module.service('myservice', [ '$http', '$q', function($http, $q) {
// Using the array syntax to declare dependencies works with minification<b>!</b>
}]);
```

这个数组语法很好的解决了这个问题。我的建议是从现在开始照这个方法写，如果你决定压缩JavaScript，这个方法可以让你少走很多弯路。好像是一个 [automatic rewriter](https://github.com/btford/ngmin) 机制，我也不太清楚这里面是怎么工作的。

最终一点建议：如果你想用数组语法复写你的functions，在所有Angular依赖注入的地方应用之。包括directives，还有directive里的controllers。别忘了逗号\(经验之谈\)

```javascript
// the directive itself needs array injection syntax:
module.directive('directive-with-controller', ['myservice', function(myservice) {
    return {
      controller: ['$timeout', function($timeout) {

//  but this controller needs array injection syntax, too!  
      }],
      link : function(scope, element, attrs, ctrl) {

      }
    }
}]);
```

_注意：_link function 不需要数组语法，因为他并没有真正的注入。这是被 Angular 直接调用的函数。Directive 级别的依赖注入在 link function 里也是使用的。

**Directive永远不会‘完成’**  
在directive中，一个令人掉头发的事就是directive已经‘完成’但你永远不会知道。当把jQuery插件整合到directive里时，这个通知尤为重要。假设你想用ng-repeat把动态数据以jQuery datatable的形式显示出来。当所有的数据在页面中加载完成后，你只需要调用$\(‘.mytable\).dataTable\(\)就可以了。 但是，臣妾做不到啊！

为啥呢？Angular的数据绑定是通过持续的digest循环实现的。基于此，Angular框架里根本没有一个时间是‘休息’的。 一个解决方法就是将jQuery dataTable的调用放在当前digest循环外，用timeout方法就可以做到。

```javascript
angular.module('table',[]).directive('mytable', ['$timeout', function($timeout) {
    return {
      restrict : 'E',
      template: '<table class="mytable">' +
                   '<thead><tr><th>counting</th></tr></thead>' +
                   '<tr ng-repeat="data in datas"><td></td></tr>' +
                '</table>',
      link : function(scope, element, attrs, ctrl) {
         scope.datas = ["one", "two", "three"]

// Doesn't work, shows an empty table:

// $('.mytable', element).dataTable()  

// But this does:
         $timeout(function() {
           $('.mytable', element).dataTable();
         }, 0)
      }
    }
}]);
```

\(实例代码 [this plunkr](http://plnkr.co/edit/ir7U3h1C26NTUpPgyeqG?p=preview) \)

在我们的代码里甚至遇到过需要双重嵌套$timeout。还有更疯狂的就是添加&lt;script&gt;tag 到模板中，这个脚本里回调Angular的scope.$apply\(\)方法。我只想说，这很不完美。基于Angular的实现机理，这很难改变。

尽管说了这么多，Angular仍然是我最爱客户端JS框架。你用Angular的时候遇到过其他的坑吗？你用什么方法解决这些问题的呢？请留言！
