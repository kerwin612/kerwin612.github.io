#用Mock.js + AngularJS来提高开发效率

在团队协作中,前端开发与后端开发是并行的.如果需要调用接口,但接口却没开发完成,怎么办?今天教大家如何使用Mock.js来构造模拟数据.

##什么是Mock.js
来自nuysoft开发的一款模拟数据生成器. 详细介绍请移步官网 [Mock.js](mockjs.com)
Mock.js提供了非常灵活强大的构造模拟数据的函数,举个例子:
```js
var data = Mock.mock({
	  'list|1-10': [{
      'id|+1': 1
	  }]
	});
console.log(data);
//{"list":[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5},{"id":6}]}
```
接下来就解决如何在接口请求中返回模拟数据:
Mock.js提供了拦截Ajax请求的方法.但内置只支持JQuery,Zepto和KISSY.
看了一下Mock.js的实现方法,jq中内置了ajaxPrefilter,轻松解决.
Zepto和KISSY的实现比较粗暴,直接覆盖了原生方法…
那么Mock.js在Angular中又是如何实现…

##AngularJS
AngularJS提供了非常灵活的Interceptors,可以ajax请求前和请求完成后对数据进行修改.

这里使用think2011的 [mock-angular](https://github.com/think2011/mock-angular) 提供了Mock.js兼容AngularJS的方法.

准备工作完成后,我们开始编写代码:

1.首先在index.html中引入mock.js和mock-angular.js
2.在主入口js中加入 Mock.mockjax(angular.module(‘test’))
3.配置mock-data.js
```js
Mock.mock('/auth/login', {
   'code': 0,
   'data': {
     'userId': '@STRING(number, 16)',
     'userName': '@CHINESENAME(2)'
	}
});
```
这时候,我们再去请求/auth/login方法,返回的结果就是模拟的数据.

这里要注意的是,在mock-angular中,请求的URL会被写为 ?mockUrl=
如果需要还原,请在mock-angular源码中修改response方法中的返回值:
```js
response: function(response) {
  var original;
  original = response.config.original;
  if (original) {
    response.data = original.result;
    console.log(original);
    //还原URL
    response.config.url = response.config.url.replace('?mockUrl=','');
  }
  return response;
}
```