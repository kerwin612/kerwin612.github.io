# 在 JavaScript 中监听 IME 键盘输入事件

在 JavaScript 中监听用户的键盘输入是很容易的事情，但用户一旦使用了输入法，问题就变得复杂了。输入法应当如何触发键盘事件呢？是每一下击键都触发一次事件，还是选词完毕才触发事件呢？整句输入又该如何触发事件呢？不同的操作系统和不同的浏览器对此有不同的看法。在最糟糕的情况下，用户使用输入法后浏览器就只触发一次 keydown ，之后就没有任何的键盘事件了。这对于 Suggestion 控件的实现来说是个大问题，因为 Suggestion 控件需要监听文本输入框的变化，而事件是最准确也最节省计算资源的做法，如果换成轮询的话性能就可能受到影响。

首先，要监听启用输入法后的击键事件应当使用 keydown 事件，这是信息最丰富的一个事件，因为在启用输入法后别的键盘事件可能不会被触发。其次，大多数操作系统和浏览器都实现了一个事实标准，就是在用户使用输入法输入时， keydown 事件传入的 keyCode 取值为 ***229*** 。然而触发 keydown 的频率是不确定的，有些情况下每一下击键都触发事件，有些情况下只有选词完毕才触发事件。这时候，如果我们还是要实时监控文本框的内容变化，就必须使用轮询了。
```js
var timer; 
var imeKey = 229; 

function keydownHandler (e) { 
  clearInterval(timer) 
  if (e.keyCode == imeKey) { 
    timer = setInterval(checkTextValue, 50); 
  } else { 
    checkTextValue(); 
  } 
} 

function checkTextValue() { 
  /* handle input text change */ 
}
```
Opera 是一款有趣的浏览器，别人做的事情它都不做，别人都不做的事情它都喜欢做。例如说，它偏偏不支持 keyCode == 229 这个事实标准，而要使用 keyCode == 197 来表示输入法的使用。因此，你需要在上述代码的基础上做一下改良，如果监测到是 Opera 浏览器，就换一个 keyCode 常量来做比较。  
`var imeKey = (UA.Opera == 0) ? 229 : 197;`  
最后，还有一个更不受重视的浏览器叫做 Firefox for Mac 。估计是因为 Mac 版本对于 Mozilla 来说实在是太不重要了，所以很多 Windows 版本都没问题的地方 Mac 版本就会出小问题，例如说对上述事件的支持。 Firefox for Mac 不会出现 keyCode == 229 的情况，而且在输入法启用后只有第一下击键会触发 keydown 事件，因此只能在击键后一直使用轮询。  
`if (e.keyCode == imeKey || UA.Firefox > 0 && UA.OS == 'Macintosh') {`  
在添加了这两项改进后，实时监控文本框的变化就没有问题了，即使用户启用了输入法。完整的代码如下：
```js
var timer; 
var imeKey = (UA.Opera == 0) ? 229 : 197; 

function keydownHandler (e) { 
  clearInterval(timer) 
  if (e.keyCode == imeKey || UA.Firefox > 0 && UA.OS == 'Macintosh') { 
    timer = setInterval(checkTextValue, 50); 
  } else { 
    checkTextValue(); 
  } 
} 

function checkTextValue() { 
  /* handle input text change */ 
}
```