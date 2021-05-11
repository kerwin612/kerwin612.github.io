# AngularJS Controller 间通信机制

在 **AngularJS开发一些经验总结** 随笔中提到我们需要按照业务却分angular controller，避免过大无所不能的上帝controller，我们把controller分离开了，但是有时候我们需要在controller中通信，一般为比较简单的通信机制，告诉同伴controller我的某个你所关心的东西改变了，怎么办？如果你是一个javascript程序员你会很自然的想到异步回调响应式通信—事件机制\(或消息机制\)。对，这就是angularjs解决controller之间通信的机制，所推荐的唯一方式，简而言之这就是angular way。

Angularjs为在scope中为我们提供了冒泡和隧道机制，$broadcast会把事件广播给所有子controller，而$emit则会将事件冒泡传递给父controller，$on则是angularjs的事件注册函数，有了这一些我们就能很快的以angularjs的方式去解决angularjs controller之间的通信，代码如下：  
View:

```markup
<div ng-app="app" ng-controller="parentCtr">
    <div ng-controller="childCtr1">name :
        <input ng-model="name" type="text" ng-change="change(name);" />
    </div>
    <div ng-controller="childCtr2">Ctr1 name:
        <input ng-model="ctr1Name" />
    </div>
</div>
```

Controller:

```javascript
angular.module("app", []).controller("parentCtr",
function ($scope) {
    $scope.$on("Ctr1NameChange",

    function (event, msg) {
        console.log("parent", msg);
        $scope.$broadcast("Ctr1NameChangeFromParrent", msg);
    });
}).controller("childCtr1", function ($scope) {
    $scope.change = function (name) {
        console.log("childCtr1", name);
        $scope.$emit("Ctr1NameChange", name);
    };
}).controller("childCtr2", function ($scope) {
    $scope.$on("Ctr1NameChangeFromParrent",

    function (event, msg) {
        console.log("childCtr2", msg);
        $scope.ctr1Name = msg;
    });
});
```

这里childCtr1的name改变会以冒泡传递给父controller，而父controller会对事件包装在广播给所有子controller，而childCtr2则注册了change事件，并改变自己。注意父controller在广播时候一定要改变事件name。

