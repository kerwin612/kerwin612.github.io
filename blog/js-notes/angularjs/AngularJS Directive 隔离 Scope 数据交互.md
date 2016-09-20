# AngularJS Directive 隔离 Scope 数据交互

####什么是隔离 Scope
>AngularJS 的 `directive` 默认能**共享父 `scope`** 中定义的属性，例如在模版中直接使用父 scope 中的对象和属性。通常使用这种直接共享的方式可以实现一些简单的 directive 功能。当你需要创建一个**可重复使用的 `directive`**，只是偶尔需要访问或者修改父 scope 的数据，就需要使用**隔离 `scope`**。当使用隔离 scope 的时候，directive 会创建一个**没有依赖父 `scope`** 的 scope，并提供一些访问父 scope 的方式。  


####为什么使用隔离 Scope
当你想要写一个可重复使用的 directive，不能再依赖父 scope，这时候就需要使用隔离 scope 代替。共享 scope 可以直接共享父 scope，而隔离 scope 无法共享父scope。下图解释共享 scope 和隔离 scope 的区别：  
![](data:image/png;base64,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)  
示例：  

**共享 scope**  
使用共享 scope 的时候，可以直接从父 scope 中共享属性。因此下面示例可以将那么属性的值输出出来。使用的是父 scope 中定义的值。  
```js
app.controller("myController", function ($scope) {
    $scope.name = "hello world";
    }).directive("shareDirective", function () {
    return {
            template: 'Say:{{name}}'
    }
});
```
```html
<div ng-controller="myController">
  <div share-directive=""></div>
</div>
```
输出结果：  
```
Say:hello world
```

**隔离 scope**  
使用隔离 scope 的时候，无法从父 scope 中共享属性。因此下面示例无法输出父 scope 中定义的 name 属性值。  
```js
app.controller("myController", function ($scope) {
    $scope.name = "hello world";
}).directive("isolatedDirective", function () {
        return {
            scope: {},
            template: 'Say:{{name}}'
        }
});
```
```html
<div ng-controller="myController">
  <div isolated-directive=""></div>
</div>
```
输出结果：  
```
Say:
```
示例请点击：http://kin-sample.coding.io/angular/directive/share-and-isolated-scope.html  

从上图可以看出共享 scope 允许从父 scope 渗入到 directive 中，而隔离 scope 不能，在隔离 scope 下，给 directive 创造了一堵墙，使得父 scope 无法渗入到 directive 中。  

具体文档可以参考：https://docs.angularjs.org/guide/directive#isolating-the-scope-of-a-directive   


####如何在 directive 中创建隔离 scope
在 directive 中创建隔离 scope 很简单，只需要定义一个 scope 属性即可，这样，这个 directive 的 scope 将会创建一个新的 scope，如果多个 directive 定义在同一个元素上，只会创建一个新的 scope。  
```js
angular.module('app').controller("myController", function ($scope) {
    $scope.user = {
            id:1,
            name:"hello world"
    };
}).directive('isolatedScope', function () {
    return {
        scope: {},
        template: 'Name: {{user.name}} Street: {{user.addr}}'
    };
});
```
现在 scope 是隔离的，user 对象将无法从父 scope 中访问，因此，在 directive 渲染的时候 user 对象的占位将不会输出内容。  


####隔离 scope 和父 scope 如何交互
directive 在使用隔离 scope 的时候，提供了三种方法同隔离之外的地方交互。这三种分别是  
**@** 绑定一个局部 scope 属性到当前 dom 节点的属性值。结果总是一个字符串，因为 dom 属性是字符串。  
**&** 提供一种方式执行一个表达式在父 scope 的上下文中。如果没有指定 attr 名称，则属性名称为相同的本地名称。  
**=** 通过 directive 的 attr 属性的值在局部 scope 的属性和父 scope 属性名之间建立双向绑定。  

- **@ 局部 scope 属性**  
@ 方式局部属性用来访问 directive 外部环境定义的字符串值，主要是通过 directive 所在的标签属性绑定外部字符串值。这种绑定是单向的，即父 scope 的绑定变化，directive 中的 scope 的属性会同步变化，而隔离 scope 中的绑定变化，父 scope 是不知道的。  

如下示例：directive 声明未隔离 scope 类型，并且使用@绑定 name 属性，在 directive 中使用 name 属性绑定父 scope 中的属性。当改变父 scope 中属性的值的时候，directive 会同步更新值，当改变 directive 的 scope 的属性值时，父 scope 无法同步更新值。  
```js
app.controller("myController", function ($scope) {
        $scope.name = "hello world";
    }).directive("isolatedDirective", function () {
        return {
            scope: {
                name: "@"
            },
            template: 'Say：{{name}} <br>改变隔离scope的name：<input type="buttom" value="" ng-model="name" class="ng-pristine ng-valid">'
        }
})
```
```html
<div ng-controller="myController">
   <div class="result">
		<div>父scope：
			<div>Say：{{name}}<br>改变父scope的name：<input type="text" value="" ng-model="name"/></div>
		</div>
		<div>隔离scope：
			<div isolated-directive name="{{name}}"></div>
		</div>
		<div>隔离scope（不使用{{name}}）：
			<div isolated-directive name="name"></div>
		</div>
	</div>
</div>
```
具体演示请看：http://kin-sample.coding.io/angular/directive/isolated-scope-at-interact.html  

- **= 局部 scope 属性**  
= 通过 directive 的 attr 属性的值在局部 scope 的属性和父 scope 属性名之间建立双向绑定。
意思是，当你想要一个双向绑定的属性的时候，你可以使用=来引入外部属性。无论是改变父 scope 还是隔离 scope 里的属性，父 scope 和隔离 scope 都会同时更新属性值，因为它们是双向绑定的关系。   

示例代码：  
```js
app.controller("myController", function ($scope) {
	$scope.user = {
		name: 'hello',
		id: 1
	};
}).directive("isolatedDirective", function () {
	return {
		scope: {
			user: "="
		},
		template: 'Say：{{user.name}} <br>改变隔离scope的name：<input type="buttom" value="" ng-model="user.name"/>'
	}
})
```
```html
<div ng-controller="myController">
    <div>父scope：
        <div>Say：{{user.name}}<br>改变父scope的name：<input type="text" value="" ng-model="user.name"/></div>
    </div>
    <div>隔离scope：
        <div isolated-directive user="user"></div>
    </div>
    <div>隔离scope（使用{{name}}）：
        <div isolated-directive user="{{user}}"></div>
    </div>
</div>
```
具体演示请看：http://kin-sample.coding.io/angular/directive/isolated-scope-eq-interact.html  

- **& 局部 scope 属性**  
& 方式提供一种途经是 directive 能在父 scope 的上下文中执行一个表达式。此表达式可以是一个 function。
比如当你写了一个 directive，当用户点击按钮时，directive 想要通知 controller，controller 无法知道 directive 中发生了什么，也许你可以通过使用 angular 中的 event 广播来做到，但是必须要在 controller 中增加一个事件监听方法。  
最好的方法就是让 directive 可以通过一个父 scope 中的 function，当 directive 中有什么动作需要更新到父 scope 中的时候，可以在父 scope 上下文中执行一段代码或者一个函数。  
  
如下示例在 directive 中执行父 scope 的 function。  
```js
app.controller("myController", function ($scope) {
	$scope.value = "hello world";
	$scope.click = function () {
		$scope.value = Math.random();
	};
}).directive("isolatedDirective", function () {
	return {
		scope: {
			action: "&"
		},
		template: '<input type="button" value="在directive中执行父scope定义的方法" ng-click="action()"/>'
	}
})
```
```html
<div  ng-controller="myController">
        <div>父scope：
            <div>Say：{{value}}</div>
        </div>
        <div>隔离scope：
            <div isolated-directive action="click()"></div>
        </div>
</div>
```
具体演示请看：http://kin-sample.coding.io/angular/directive/isolated-scope-ad-interact.html  


####使用小结
在了解 directive 的隔离 scope 跟外部环境交互的三种方式之后，写一些通用性的组件更加便捷和顺手。不再担心在 directive 中改变外部环境中的值，或者执行函数的重重困境了。  
更多请参考API文档：https://docs.angularjs.org/api/ng/service/$compile 。  
如有纰漏，请指正！  

转自：https://blog.coding.net/blog/angularjs-directive-isolate-scope  