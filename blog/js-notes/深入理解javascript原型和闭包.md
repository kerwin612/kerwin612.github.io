# 深入理解javascript原型和闭包

###说明：

　　该教程绕开了 javascript 的一些基本的语法知识，直接讲解 javascript 中最难理解的两个部分，也是和其他主流面向对象语言区别最大的两个部分——**原型**和**闭包**，当然，肯定少不了**原型链**和**作用域链**。帮你揭开 javascript 最神秘的面纱。  

　　为什么要偏偏要讲这两个知识点？  

　　这是我在这么多年学习 javascript 的经历中，认为最难理解、最常犯错的地方，学习这两个知识点，会让你对 javascript 有更深层次的理解，至少理解了原型和作用域，就不能再算是 javascript 菜鸟了。另外，这两方面也是 javascript 与其他语言不同的地方，学习这样的设计，有助于你开阔眼界，帮助你了解编程语言的设计思路。毕竟，你不能只把眼睛盯在一门语言上。  

　　闲话不多讲，相信奔着这个话题来的朋友，也知道 javascript **原型**和**作用域**的重要性。  

　　最后说明：本系列教程我不是照搬的其他图书或者网络资料，而是全凭着我对知识的理解而一步一步写的。思路也是我一边写着一边想的。有什么不对的地方，欢迎指正。  
  
  
##目录：

[深入理解javascript原型和闭包（1）——一切都是对象](#1)  
[深入理解javascript原型和闭包（2）——函数和对象的关系](#2)  
[深入理解javascript原型和闭包（3）——prototype原型](#3)  
[深入理解javascript原型和闭包（4）——隐式原型](#4)  
[深入理解javascript原型和闭包（5）——instanceof](#5)  
[深入理解javascript原型和闭包（6）——继承](#6)  
[深入理解javascript原型和闭包（7）——原型的灵活性](#7)  
[深入理解javascript原型和闭包（8）——简述【执行上下文】上](#8)  
[深入理解javascript原型和闭包（9）——简述【执行上下文】下](#9)  
[深入理解javascript原型和闭包（10）——this](#10)  
[深入理解javascript原型和闭包（11）——执行上下文栈](#11)  
[深入理解javascript原型和闭包（12）——简介【作用域】](#12)  
[深入理解javascript原型和闭包（13）——【作用域】和【上下文环境】](#13)  
[深入理解javascript原型和闭包（14）——从【自由变量】到【作用域链】](#14)  
[深入理解javascript原型和闭包（15）——闭包](#15)  
[深入理解javascript原型和闭包（16）——完结](#16)  

后补：  
[深入理解javascript原型和闭包（17）——补this](#17)  
[深入理解javascript原型和闭包（18）——补充：上下文环境和作用域的关系](#18)  



#<span id="1">1. 一切都是对象</span>
“**一切都是对象**”这句话的重点在于如何去理解“**对象**”这个概念。  
——当然，也不是所有的都是对象，值类型就不是对象。  
 

首先咱们还是先看看 javascript 中一个常用的函数——`typeof()`。`typeof`应该算是咱们的老朋友，还有谁没用过它？  
  
`typeof`函数输出的一共有几种类型，在此列出：  
```js
function show(x) {
	console.log(typeof(x));    // undefined
	console.log(typeof(10));   // number
	console.log(typeof('abc')); // string
	console.log(typeof(true));  // boolean

	console.log(typeof(function () { }));  //function

	console.log(typeof([1, 'a', true]));  //object
	console.log(typeof ({ a: 10, b: 20 }));  //object
	console.log(typeof (null));  //object
	console.log(typeof (new Number(10)));  //object
}
show();
```
以上代码列出了`typeof`输出的集中类型标识，其中上面的四种（`undefined`, `number`, `string`, `boolean`）属于简单的**值类型**，不是对象。剩下的几种情况——`函数、数组、对象、null、new Number(10)`都是对象。他们都是**引用类型**。  
  
判断一个变量是不是对象非常简单。值类型的类型判断用`typeof`，**引用类型**的类型判断用`instanceof`。  
```js
var fn = function () { };
console.log(fn instanceof Object);  // true
```
好了，上面说了半天对象，各位可能也经常在工作中应对对象，在生活中还得应对活生生的对象。有些个心理不正常或者爱开玩笑的单身人士，还对于系统提示的“找不到对象”耿耿于怀。那么在 javascript 中的对象，到底该如何定义呢？    
**对象——若干属性的集合。**  
java 或者 C# 中的对象都是 new 一个 class 出来的，而且里面有字段、属性、方法，规定的非常严格。但是 javascript 就比较随意了——数组是对象，函数是对象，对象还是对象。对象里面的一切都是属性，只有属性，没有方法。那么这样方法如何表示呢？——方法也是一种属性。因为它的属性表示为键值对的形式。  
而且，更加好玩的事，javascript 中的对象可以任意的扩展属性，没有 class 的约束。这个大家应该都知道，就不再强调了。  

先说个最常见的例子：  
![](data:image/png;base64,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)  
以上代码中，obj是一个自定义的对象，其中a、b、c就是它的属性，而且在c的属性值还是一个对象，它又有name、year两个属性。  


这个可能比较好理解，那么函数和数组也可以这样定义属性吗？——当然不行，但是它可以用另一种形式，总之函数/数组之流，只要是对象，它就是属性的集合。  
  
以函数为例子：  
```js
var fn = function () {
	alert(100);
};
fn.a = 10;
fn.b = function () {
	alert(123);
};
fn.c = {
	name: "王福朋",
	year: 1988
};
```
上段代码中，函数就作为对象被赋值了a、b、c三个属性——很明显，这就是属性的集合吗。  
你问：这个有用吗？  
回答：可以看看 jQuery源码！  
在 jQuery源码 中，“`jQuery`”或者“`$`”，这个变量其实是一个函数，不信你可以叫咱们的老朋友`typeof`验证一下。  
```js
console.log(typeof ($));  // function
console.log($.trim(" ABC "));
```
验明正身！的确是个函数。那么咱们常用的 $.trim() 也是个函数，经常用，就不用验了吧！   
很明显，这就是在$或者jQuery函数上加了一个trim属性，属性值是函数，作用是截取前后空格。   

javascript 与 java/C# 相比，首先最需要解释的就是弱类型，因为弱类型是最基本的用法，而且最常用，就不打算做一节来讲。   
其次要解释的就是本文的内容——**一切（引用类型）都是对象，对象是属性的集合**。最需要了解的就是对象的概念，和 java/C# 完全不一样。所以，切记切记！  

最后，有个疑问。在`typeof`的输出类型中，`function`和`object`都是对象，为何却要输出两种答案呢？都叫做`object`不行吗？——当然不行。  
具体原因，且听下回分解！  


#<span id="1">2. 函数和对象的关系</span>
上文（[1. 一切都是对象](#1)）已经提到，函数就是对象的一种，因为通过`instanceof`函数可以判断。  
```js
var fn = function () { };
console.log(fn instanceof Object);  // true
```
对！函数是一种对象，但是函数却不像数组一样——你可以说数组是对象的一种，因为数组就像是对象的一个子集一样。但是函数与对象之间，却不仅仅是一种包含和被包含的关系，函数和对象之间的关系比较复杂，甚至有一点鸡生蛋蛋生鸡的逻辑，咱们这一节就缕一缕。   

还是先看一个小例子吧。
```js
function Fn() {
	this.name = '王福朋';
	this.year = 1988;
}
var fn1 = new Fn();
```
上面的这个例子很简单，它能说明：对象可以通过函数来创建。对！也只能说明这一点。  

但是我要说——**对象都是通过函数创建的**——有些人可能反驳：不对！因为：  
```js
var obj = { a: 10, b: 20 };
var arr = [5, 'x', true];
```
但是不好意思，这个——真的——是一种——“快捷方式”，在编程语言中，一般叫做“语法糖”。  

做“语法糖”做的最好的可谓是微软大哥，它把他们家 C# 那小子弄的不男不女从的，本想图个人见人爱，谁承想还得到处跟人解释——其实它是个男孩！    

话归正传——其实以上代码的本质是：  
```js
//var obj = { a: 10, b: 20 };
//var arr = [5, 'x', true];

var obj = new Object();
obj.a = 10;
obj.b = 20;

var arr = new Array();
arr[0] = 5;
arr[1] = 'x';
arr[2] = true;
```
而其中的 Object 和 Array 都是函数：  
```js
console.log(typeof (Object));  // function
console.log(typeof (Array));  // function
```
所以，可以很负责任的说——**对象都是通过函数来创建的**。  

现在是不是糊涂了—— 对象是函数创建的，而函数却又是一种对象——天哪！函数和对象到底是什么关系啊？  
别着急！揭开这个谜底，还得先去了解一下另一位老朋友——`prototype`原型。    

本系列文章不打算动辄几千字的长篇大论，咱们小步快跑，不至于看的太乏味。  



#<span id="3">3. prototype原型</span>
既`typeof`之后的另一位老朋友！  

`prototype`也是我们的老朋友，即使不了解的人，也应该都听过它的大名。如果它还是您的新朋友，我估计您也是javascript 的新朋友。    




#<span id="4">4. 隐式原型</span>



#<span id="5">5. instanceof</span>



#<span id="6">6. 继承</span>



#<span id="7">7. 原型的灵活性</span>



#<span id="8">8. 简述【执行上下文】上</span>



#<span id="9">9. 简述【执行上下文】下</span>



#<span id="10">10. this</span>



#<span id="11">11. 执行上下文栈</span>



#<span id="12">12. 简介【作用域】</span>



#<span id="13">13. 【作用域】和【上下文环境】</span>



#<span id="14">14. 从【自由变量】到【作用域链】</span>



#<span id="15">15. 闭包</span>



#<span id="16">16. 完结</span>



#<span id="17">17. 补this</span>



#<span id="18">18. 补充：上下文环境和作用域的关系</span>





