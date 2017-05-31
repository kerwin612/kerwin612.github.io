# 如何组织大型JavaScript应用中的代码？

**英文原文：**[http://cliffmeyers.com/blog/2013/4/21/code-organization-angularjs-javascript](http://cliffmeyers.com/blog/2013/4/21/code-organization-angularjs-javascript)   

本文作者Cliff Meyers是一个前端工程师，熟悉HTML5、JavaScript、J2EE开发，他在开发过程中总结了自己在应对JavaScript应用越来越庞大情况下的文件结构，深得其他开发者认可。以下为CSDN编译：      

**地板上堆放的衣服**  

首先，我们来看看angular-seed，它是AngularJS应用开发的官方入门项目，其文件结构是这样的：    
  * css/
  * img/
  * js/
    * app.js
    * controllers.js
    * directives.js
    * filters.js
    * services.js
  * lib/
  * partials/  

看起来就像是把衣服按类型堆在地板上，一堆袜子、一堆内衣、一堆衬衫等等。你知道拐角的那堆袜子里有今天要穿的黑色羊毛袜，但你仍需要花上一段时间来寻找。   

这种组织方式很凌乱。一旦你的代码中存在6、7个甚至更多的控制器或者服务，文件管理就会变得难以处理——很难找到想要寻找的对象，源代码控制中的文件也变更集变得难懂。   

**袜子抽屉**

常见的JavaScript文件结构还有另一种形式，即按原型将文件分类。我们继续用整理衣服来比喻——现在我们买了有很多抽屉的衣柜，打算将袜子放在其中一个抽屉里，内衣放在另一个抽屉，再把衬衫整齐地叠在第三个抽屉……  

想象一下，我们正在开发一个简单的电子商务网站，包括登陆流程、产品目录以及购物车UI。同样，我们将文件分为以下几个原型：models（业务逻辑和状态）、controllers以及services（HTTP/JSON端点加密），而按照Angular默认那样非笼统地归到“service”架构。因此我们的JavaScript目录变成了这样：   
* controllers/
  * LoginController.js
  * RegistrationController.js
  * ProductDetailController.js
  * SearchResultsController.js
* directives.js
* filters.js
* models/
  * CartModel.js
  * ProductModel.js
  * SearchResultsModel.js
  * UserModel.js
* services/
  * CartService.js
  * UserService.js
  * ProductService.js

不错，现在已经可以通过树形文件目录或者IDE快捷键更方便地查找文件了，源代码控制中的变更集（changeset）也能够清楚地描述文件修改记录。虽然已经获得了极大的改进，但是仍有一定的局限性。  

想象一下，你现在正在办公室，突然发现明天有个商务出差，需要几套干洗的衣服，因此给家里打电话告诉另一半把黑色和蓝色的西装交给清洁工，还有黑纹领带配灰色衬衫、白衬衫配纯黄领带。如果你的另一半并不熟悉衣柜，又该如何从三条黄色的领带中挑出你的正确需求？   

**模块化**   

希望衣服的比喻没有让你觉得过于陈旧，下面举一个实例：  
* 你的搭档是新来的开发者，他被要求去修补这个复杂应用中的一处bug。
* 他扫过这些文件夹，看到了controllers、models、services等文件夹整齐地排列着，但是他仍然不清楚对象间的依赖关系。
* 处于某些原因，他希望能够重用部分代码，这需要从各个文件夹中搜集相关文件，而且常常会遗漏某些文件夹中的对象。
  
信或不信，你确实很少会在新项目中重用很多代码，但你很可能需要重用登陆系统这样的整个模块。所以，是不是按功能划分文件会更好？下面的文件结构是以功能划分后的应用结构：   
* cart/
  * CartModel.js
  * CartService.js
* common/
  * directives.js
  * filters.js
* product/
  * search/
    * SearchResultsController.js
    * SearchResultsModel.js
  * ProductDetailController.js
  * ProductModel.js
  * ProductService.js
* user/
  * LoginController.js
  * RegistrationController.js
  * UserModel.js
  * UserService.js

虽然现实世界中有空间限制，难以随意整理服装，但是编程中类似的处理却是零成本的。  

现在即使是新来的开发者也能通过顶级文件夹的命名理解应用的功能，相同文件夹下的文件会存在互相依赖等关系，而且仅仅通过浏览文件组织结构就能轻易理解登录、注册等功能的原理。新的项目也可以通过复制粘贴来重用其中的代码了。   

使用AngularJS我们可以进一步将相关代码组织为模块：   
```js
var userModule = angular.module('userModule',[]);   
userModule.factory('userService', ['$http', function($http) { 
  return new UserService($http); 
}]);    
userModule.factory('userModel', ['userService', function(userService) { 
  return new UserModel(userService); 
}]);    
userModule.controller('loginController', ['$scope', 'userModel', LoginController]);  
userModule.controller('registrationController', ['$scope', 'userModel', RegistrationController]);
```
如果我们将UserModule.js文件放到user文件夹，它就成了这个模块中使用到的对象的“manifest”，这也是适合RequireJS或者Browserify中放置某些加载指令的地方  


**如何处理通用代码**  

每个应用都会有某些代码广泛使用在多个模块中，我们常常使用名为“commom”或者“shared”的文件夹来存放这些功能代码。又该如何处理这些通用代码呢？  
* 如果模块中的对象需要直接访问几个“通用”对象，为这些对象提供几个Facade（外观模式）。这有助于减少每个对象的依赖者，而过多的关联对象通常意味着糟糕的代码结构。
* 如果“通用”模块变得过于庞大，你需要将它按功能领域细分为多个子模块。确保每个应用模块只使用它需要的“通用”模块，这即是SOLID中“接口隔离原则”的变种。
* 在根范围（$rootScope）添加实体，这样子范围也可以使用，适合多个控制器都依赖同一个对象（比如“PermissionsModel”）的情况。
* 在解耦两个不明确互相引用的组件时，请使用事件。Angular中Scope对象的$emit、$broadcast以及$on方法使得这种方式变得现实。控制器能够触发一个事件来执行某些动作，然后再动作结束后收到相应地通知。  