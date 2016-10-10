# 深入理解javascript原型和闭包

###说明：

　　该教程绕开了javascript的一些基本的语法知识，直接讲解javascript中最难理解的两个部分，也是和其他主流面向对象语言区别最大的两个部分——原型和闭包，当然，肯定少不了原型链和作用域链。帮你揭开javascript最神秘的面纱。  

　　为什么要偏偏要讲这两个知识点？  

　　这是我在这么多年学习javascript的经历中，认为最难理解、最常犯错的地方，学习这两个知识点，会让你对javascript有更深层次的理解，至少理解了原型和作用域，就不能再算是javascript菜鸟了。另外，这两方面也是javascript与其他语言不同的地方，学习这样的设计，有助于你开阔眼界，帮助你了解编程语言的设计思路。毕竟，你不能只把眼睛盯在一门语言上。  

　　闲话不多讲，相信奔着这个话题来的朋友，也知道javascript原型和作用域的重要性。  

　　最后说明：被系列教程我不是照搬的其他图书或者网络资料，而是全凭着我对知识的理解而一步一步写的。思路也是我一边写着一边想的。有什么不对的地方，欢迎指正。  
  
  
##目录：

[深入理解javascript原型和闭包（1）——一切都是对象]()  
[深入理解javascript原型和闭包（2）——函数和对象的关系]()  
[深入理解javascript原型和闭包（3）——prototype原型]()  
[深入理解javascript原型和闭包（4）——隐式原型]()  
[深入理解javascript原型和闭包（5）——instanceof]()  
[深入理解javascript原型和闭包（6）——继承]()  
[深入理解javascript原型和闭包（7）——原型的灵活性]()  
[深入理解javascript原型和闭包（8）——简述【执行上下文】上]()  
[深入理解javascript原型和闭包（9）——简述【执行上下文】下]()  
[深入理解javascript原型和闭包（10）——this]()  
[深入理解javascript原型和闭包（11）——执行上下文栈]()  
[深入理解javascript原型和闭包（12）——简介【作用域】]()  
[深入理解javascript原型和闭包（13）-【作用域】和【上下文环境】]()  
[深入理解javascript原型和闭包（14）——从【自由变量】到【作用域链】]()  
[深入理解javascript原型和闭包（15）——闭包]()  
[深入理解javascript原型和闭包（16）——完结]()  

后补：
[深入理解javascript原型和闭包（17）——补this]()  
[深入理解javascript原型和闭包（18）——补充：上下文环境和作用域的关系]()  




#1. 深入理解javascript原型和闭包（1）——一切都是对象 
“**一切都是对象**”这句话的重点在于如何去理解“**对象**”这个概念。  
——当然，也不是所有的都是对象，值类型就不是对象。  
 

首先咱们还是先看看javascript中一个常用的函数——`typeof()`。`typeof`应该算是咱们的老朋友，还有谁没用过它？  
  
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
以上代码列出了`typeof`输出的集中类型标识，其中上面的四种（`undefined`, `number`, `string`, `boolean`）属于简单的值类型，不是对象。剩下的几种情况——`函数、数组、对象、null、new Number(10)`都是对象。他们都是**引用类型**。  
  
判断一个变量是不是对象非常简单。值类型的类型判断用`typeof`，**引用类型**的类型判断用`instanceof`。  



