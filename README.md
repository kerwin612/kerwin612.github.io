# Introduction

## Markdown 基本语法

## 段落

非常自然，一行文字就是一个段落。

比如

```text
这是一个段落。
```

会被解释成

```text
<p>这是一个段落。</p>
```

如果你需要另起一段，请在两个段落之间隔一个空行。

```text
这是一个段落。

这是另一个段落。
```

会解释成

```text
<p>这是一个段落<p>
<p>这是另一个段落</p>
```

不隔一个空行的换行行为，在一些编辑器中被解释为换行，即插入一个`<br/>`标签。对与另外一些编辑器，会被解释为插入一个空格。对于后者，若要插入换行标签，请在当前一行的结尾打两个空格。

如果想实现缩进

```text
直接写
半方大的空白&ensp;或&#8194;
全方大的空白&emsp;或&#8195;
不断行的空白格&nbsp;或&#160;
```

## 粗体、斜体

可以使用星号`*`或下划线`_`指定粗体或者斜体。

```text
*这是斜体*
_这也是斜体_
**这是粗体**
***这是粗体+斜体***
```

会被解释成

```text
<em>这是斜体</em>
<em>这也是斜体</em>
<strong>这是粗体</strong>
<strong><em>这是粗体+斜体</strong></em>
```

## 删除线

一部分编辑器支持删除线，它不是经典markdown中的要素。用波浪线`~`定义删除线。

```text
~~就像这样~~
```

会被解释成

```text
<strike>就像这样</strike>
```

## 标题

markdown总支持1~6六级标题，通过在一行之前加上不同数量的井号来表示。

```text
# 这是 H1 #

## 这是 H2 ##

### 这是 H3 ###

...

###### 这是 H6 ######
```

行尾可以加上任意数量的井号字符，这些字符不会算作标题内容。通常会加上相等数量的字符以保持对称。

此外，H1和H2也可以采用在文本下方添加底线来实现，比如：

```text
这是 H1
=======

这是 H2
-------
```

## 引用

通过在行首加上大于号`>`来添加引用格式。

```text
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.
```

引用可以嵌套：

```text
> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.
```

也可以嵌套其他格式：

```text
> ## 这是一个标题。
>
> 1\.   这是第一行列表项。
> 2\.   这是第二行列表项。
>
> 给出一些例子代码：
>
>     return shell_exec("echo $input | $markdown_script");
```

## 列表

无序列表使用星号、加号或是减号作为列表标记：

```text
*   Red
*   Green
*   Blue
```

等同于

```text
+   Red
+   Green
+   Blue
```

和

```text
-   Red
-   Green
-   Blue
```

有序列表则使用数字接着一个英文句点：

```text
1.  Bird
2.  McHale
3.  Parish
```

数字并不会影响输出的 HTML 结果，也就是说上面的例子等同于：

```text
1.  Bird
1.  McHale
1.  Parish
```

## 内联代码

用反引号````` 来标记内联代码，它们会解释成```&lt;code&gt;`标签。如果代码的内容中有反引号，请用两个反引号包裹。代码中的`&`、`&lt;`、`&gt;\`符号都会自动转义，请放心使用。

## 代码区域

有两种方式标记代码区域，原生风格是行首缩进四个空格。

```text
这是一个普通段落：

    这是一个代码区块。
```

会被解释成

```text
<p>这是一个普通段落：</p>

<pre><code>这是一个代码区块。
</code></pre>
```

除了行首的4个空格会被移出，其它不变。像内联代码一样，上述三种符号也会被转义。但在代码段中，星号之类的markdown标记符号则不会解析。

还有一种是github的风格，代码段的前后用三个反引号独占一行来标记。

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPgAAABKCAIAAAAZsQ4iAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAMXSURBVHhe7ddBTqMxDIbhORQn5wC9QxfcggV7WIzBIXKTOPlb8ovRfO+zGCW2E3XIpwr+vL+/fwD/O4IOCQQdEgg6JBB0SCDokEDQIWFX0F+vl+fLy1vZ3Zr0ZseAfTZ+o1toL9fXsmlMerNjwCb86gIJBB0SCDokEHRIIOiQQNAhgaBDAkGHBIIOCQQdEgg6JBB0SCDokEDQIYGgQwJBhwSCDgkEHRIIOiQQdEgg6JBA0CGBoEMCQYeEs4L+9PRUViPWzZSJTY5cGGc2foDP/8xKGf0y3+KH9gR9+CqTp8pa21/3yIVxpq6XB22gURrf+spcM3/vccxt+0a/66WtlSkTO/htyzvjQLY2to1K9duRSjVs1aItet7CwzYH3V9lyMdcs62y+gPiVZNrJx9seCob6Ie9srykaopxO5zHXU7/YzR71EyZ+Jn+nuzmpl63tnC+rWIlW7taaVrDyagWfWHiGo/5naCfKotI/0ms4kVfRD7QaOpx2x/Juv2ka+pHjuC4DUG3Z3BlHx4mFt3X4FqZvnM+rl2/rRVf1K1rto3Pw9+abeWTJq6Nb5tiNJx3k1M46Kw/Rn175IVOfcXl5cOPPWSt2s3GYr2fyU4579q/GR/DY84Kupm8TWyd+oTLyx/72NlMrDczvs0OmnvnjXXnA6h+5xs91m0dleomywv7gcmR2rJFLw6YI+vI6q5u679DzSTmTgl6tq6WA7ssL59/vKab1atYnww3Fdu6sk/uadR6NoBof9D7n/u8cuo7LS/PBrzedG1bldKtWPf1cDI7XvX3DFlr0kW0J+j+4z74Q2+GT32q5eWTAWs13bpt6lWsZzNL/cGHr0K1IejN62bqgC+M14fKxI8tr5oPHP8knx/6dtgrc2U0GBZNVsdB2351Af5lBB0SCDokEHRIIOiQQNAhgaBDAkGHBIIOCQQdEgg6JBB0SCDokEDQIYGgQwJBh4RdQX+9Xp4vL29ld2vSmx0D9tn4jW6hvVxfy6Yx6c2OAZvwqwskEHRIIOiQQNAhgaBDAkGHBIIOCQQdEgg6BHx8/AXj0Tw/c7EseAAAAABJRU5ErkJggg==)

目前主流编辑器都支持这种风格。

## 分隔线

你可以在一行中用三个以上的星号、减号、底线来建立一个分隔线，行内不能有其他东西。你也可以在星号或是减号中间插入空格。下面每种写法都可以建立分隔线：

```text
* * *
***
*****
- - -
---------------------------------------
```

## 链接

```text
[an example](http://example.com/)
[an example](http://example.com/ "Optional Title")
```

会被解释为

```text
<a href='http://example.com/'>an example</a>
<a href='http://example.com/' title="Optional Title">an example</a>
```

除了上面的行内式，也可以使用参考式：

```text
[an example][id]
```

然后在任意空白位置定义：

```text

```

## 图像

```text
![Alt text](/path/to/img.jpg)
![Alt text](/path/to/img.jpg "Optional Title")
```

会被解释为

```text
<img src='/path/to/img.jpg' alt='Alt text' />
<img src='/path/to/img.jpg' alt='Alt text' title='Optional Title' />
```

同样，图像也有类似的参考式语法。

## 自动链接

如果链接的地址和名字重复，可以用尖括号语法将其简化。

```text
<http://example.com/>
```

就相当于

```text
[http://example.com/](http://example.com/)
```

切记，大多数编辑器都会自动将符合url规则的东西视为链接，并且解释成链接。很多时候作者由于疏忽等缘故，链接和后面的中文之间缺少空格，导致链接不正常。所以我建议，链接要么加上尖括号，要么两端加上空格。

## 转义

markdown支持在以下字符前面插入反斜杠

```text
\   反斜线
`   反引号
*   星号
_   底线
{}  花括号
[]  方括号
()  括弧
#   井字号
+   加号
-   减号
.   英文句点
!   惊叹号
```

插入之后，将不再解析这些字符，而是原样输出。

## 表格

表格是github风格独有的语法，但近年来渐渐被大多数编辑器支持。

```text
| Item     | Value | Qty   |
| :------- | ----: | :---: |
| Computer | $1600 |  5    |
| Phone    | $12   |  12   |
| Pipe     | $1    |  234  |
```

会被解释成

```text
<table>
<thead>
<tr>
  <th align="left">Item</th>
  <th align="right">Value</th>
  <th align="center">Qty</th>
</tr>
</thead>
<tbody><tr>
  <td align="left">Computer</td>
  <td align="right">$1600</td>
  <td align="center">5</td>
</tr>
<tr>
  <td align="left">Phone</td>
  <td align="right">$12</td>
  <td align="center">12</td>
</tr>
<tr>
  <td align="left">Pipe</td>
  <td align="right">$1</td>
  <td align="center">234</td>
</tr>
</tbody></table>
```

要注意第二行的冒号决定了居左居右还是居中，如果你不加冒号，默认是居左的。

另外可以把第一行去掉，做成没有表头的表格，但第二行始终是要有的。

## 内联 HTML <a id="html"></a>

markdown 的语法简洁，但有其局限性，所以特意保留了内联html这种方式。任何html标签及其内容，都会原样输出到结果中。也就是说，标签中的星号等作为markdown结构的符号，以及构成html标签和实体的符号，都不会做任何转义。

