# JS / JQuery 代码、框架收藏

## JS/jQuery 代码、框架收藏

### DD\_roundies是一个圆角边框创建脚本，不需要借助任何图片。大小只有3.62Kb。

[主页](http://dillerdesign.com/experiment/DD_roundies/) [下载](http://dillerdesign.com/experiment/DD_roundies/#download) [示例](http://dillerdesign.com/experiment/DD_roundies/#background_properties)

### jQuery-zclip是一个复制内容到剪贴板的jQuery插件，使用它我们不用考虑不同浏览器和浏览器版本之间的兼容问题。jQuery-zclip插件需要Flash的支持，使用时记得安装Adobe Flash Player。

[主页](http://www.steamdev.com/zclip/)

```javascript
//引入jQuery-zclip相关js及swf文件 
<script type="text/javascript" src="<%=path%>/resources/js/jquery.min.js"></script> 
<script type="text/javascript" src="<%=path%>/resources/js/jquery.zclip.min.js"></script> 
<script type="text/javascript"> 
$(function(){ 
    $("#cp-btn").zclip({ 
        path:'<%=path%>/resources/js/ZeroClipboard.swf', //记得把ZeroClipboard.swf引入到项目中  
        copy:function(){ 
            return $('#inviteUrl').val(); 
        } 
    }); 
}); 
</script> 

<div class=form-row> 
    <div class=col-md-5> 
        <input class=form-control value="" id="inviteUrl"/> 
    </div> 
    <div class=col-md-1> 
        <a href="javascript:void(0)" id="cp-btn"
            class="btn btn-default btn-block btn-clean">复  制</a> 
    </div> 
</div>
```

**配置说明**: 1. _**path**_:swf的路径\(复制主要是用flash解决不同浏览器的复制\) 2. _**copy**_:待复制的内容, 可以是静态内容, 也可以 return 动态内容 3. _**beforeCopy**_:复制之前要做的function 4. _**afterCopy**_:复制之后要做的function

**提供了3个方法**: 1. _**show**_:$\(selected\).zclip\('show'\);//复制功能有效 2. _**hide**_:$\(selected\).zclip\('hide'\);//复制功能无效 3. _**remove**_:$\(selected\).zclip\('remove'\);//完全移除复制功能

## 代码收藏

### 代码实现A标签跳转解决window.open\(\)打开页面被拦截的问题

```javascript
var a = document.createElement("a");    
a.setAttribute("href", url);    
a.setAttribute("target", "_blank");    
document.body.appendChild(a);    
if (document.all) {    
    // For IE     
    a.click();     
} else if (document.createEvent) {    
    //FOR DOM2    
    var e = document.createEvent('HTMLEvents');     
    e.initEvent('click', false, true);    
    a.dispatchEvent(e);    
}
```

### 利用Keydown事件阻止用户输入

```javascript
var input = document.getElementById('number_ipt')

input.onkeydown = function(event) {
    if ( !isNumber(event.keyCode || event.which) || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey ) event.preventDefault();      
}

// 仅能输入数字
function isNumber(keyCode) {
    // 数字
    if (keyCode &gt;= 48 &amp;&amp; keyCode &lt;= 57 ) return true;
    // 小数字键盘
    if (keyCode &gt;= 96 &amp;&amp; keyCode &lt;= 105) return true;
    // Backspace键
    if (keyCode == 8) return true;
    return false;
}
```

