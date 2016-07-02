#SpringMVC中用@ParamVariable传递的参数包含斜杠(/)时，匹配不了报404错误的解决方案

今天做网站【标签】筛选功能时，出现了这么个奇葩的问题。
我是直接通过&lt;a&gt;标签中href来跳转的，url中包含汉字&lt;/a&gt;
```html
<a href="/tags/标签A">标签A</a>
```
后台代码是这样的：
```java
@RequestMapping(value = "/tags/{tagname}")
public String tags(@PathVariable String tagname) {
　　 // ISO-8859-1 ==> UTF-8 进行编码转换
　　 tagname = encode_to_utf8(tagname);
　　 // 其余处理略
}
```
按理说这样就行了，各大浏览器也正常执行了。  

但是，一不下心发现，只要URL中出现“&lt;strong&gt;充&lt;/strong&gt;”这个汉字，直接就报404错误  

例如这样：
```html
<a href="/tags/标签充A">标签充A</a>
```
奇葩吧。  

经过漫长的调查发现，原因 有可能 是：  

&lt;strong&gt;充&lt;/strong&gt; 这个汉字在URL中直接提交，经过浏览器转码后，会变成一串包含“ &lt;strong&gt;/ &lt;/strong&gt; ”的“乱码”。  

后来经过类似测试发现，果然只要URL中包含“ &lt;strong&gt;/&lt;/strong&gt; ”的参数，都无法通过@PathVariable 正确匹配。  

有人说不如改成这样：  

方案1：  

在Server端通过urlencode把汉字先进行UTF-8编码，然后扔到前端。  

但是这样做的话，URL就会变成这个丑样，这和乱码有什么区别？真心不喜欢。  
```html
<a href="/tags/%D6%D0%B9%FA">标签充A</a>
```
还有人说可以这样  

方案2：
```html
<a href="/tags?tagname=标签充A">标签充A</a>
```
然后在Controller中用 @RequestParam 来接收参数，这样确实是可以的。  

但是SEO大神说，url中包含?的动态参数后，有可能会被蜘蛛重复抓取，不利于SEO。  

难道就没有办法在保持URL格式与汉字都不变的情况，实现这个功能吗？  

最后终于发现，有人这样搞定了！  

前端：
```html
<a href="/tags/标签充A">标签充A</a>
```
后端：
```java
@RequestMapping(value = "/tags/**")
public String tags(HttpServletRequest request) {
　　 // ISO-8859-1 ==> UTF-8 进行编码转换
　　String tagname = extractPathFromPattern(request);
      tagname = ToolUtils.encodeStr(tagname);
　　 // 其余处理略
}

// 把指定URL后的字符串全部截断当成参数
// 这么做是为了防止URL中包含中文或者特殊字符（/等）时，匹配不了的问题
private static String extractPathFromPattern(
            final HttpServletRequest request)
{
     String path = (String) request.getAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE);
     String bestMatchPattern = (String) request.getAttribute(HandlerMapping.BEST_MATCHING_PATTERN_ATTRIBUTE);
     return new AntPathMatcher().extractPathWithinPattern(bestMatchPattern, path);
}
```
搞完之后，不管你输入什么样的URL，都能进入到指定的方法！  
```html
<a href="/tags/标签充A">标签充A</a>
<a href="/tags/标签充A/asd/asd">标签充A</a>
<a href="/tags/标签充A/BB/cc.html">标签充A</a>
```

**@PathVariable 包含斜杠**
```java
@RequestMapping(value = "/{collectionName}/products/**")
public String productDetail(Model model,HttpServletRequest request, @PathVariable String collectionName) {
```
@PathVariable的值包含斜杠，如：/collections/Cleansers/products/A/B  

用正则替换不需要的字符串  
```java
request.getPathInfo().replaceAll("^/collections?[-\w.\s\/]+/products/","")
```