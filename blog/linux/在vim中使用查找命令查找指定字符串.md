# 在vim中使用查找命令查找指定字符串

要自当前光标位置***向上***搜索，请使用以下命令：      
`/pattern Enter`    
&emsp;其中， pattern 表示要搜索的特定字符序列。     
    
要自当前光标位置***向下***搜索，请使用以下命令：     
`?pattern Enter`    
&emsp;按下 Enter 键后， vi 将搜索指定的 pattern ，并将光标定位在 pattern 的第一个字符处。    
    
例如，要向上搜索 place 一词，请键入：    
`/place Enter`    
&emsp;如果 vi 找到了 place ，它将把光标定位在 p 处。要搜索 place 的其他匹配，请按 n 或 N：    
&emsp;&emsp;n，继续朝同一方向搜索 place。     
&emsp;&emsp;N，反方向进行搜索。    
&emsp;如果 vi 未找到指定的 pattern ，光标位置将不变，屏幕底部显示以下消息：   
&emsp;*Pattern: 未找到*    
  
搜索特殊匹配     
&emsp;在上面的示例中， vi 查找到包含 place 的任何序列，其中包括 displace、placement 和 replaced。   
&emsp;要查找单个的 place ，请键入该单词，并在其前后各加一个空格：   
&emsp;&emsp;`/ place  Enter`   
&emsp;要查找仅出现在行首的 place ，请在该单词前加一个插字符号(^)：   
&emsp;&emsp;`/^place Enter`        
&emsp;要查找仅出现在行尾的   place，请在该单词后加一个货币符号($)：     
&emsp;&emsp;`/place$ Enter`   
       
**使用 ^**   
&emsp;要逐字搜索这种带有插字符号 (^) 或货币符号 ($) 的字符，请在字符前加一个反斜线 (\\)。反斜线命令 vi 搜索特殊字符。   
**使用 $**   
&emsp;特殊字符是指在 vi 中具有特殊功能的字符（例如   ^、$、\*、/   和   .）。例如，$ 通常表示“转至行尾”，但是，如果   $   前紧跟一个   \\，则   $   只是一个普通的字符。   
**使用 \\**    
&emsp;例如，/(No   \\$   money)   向上搜索字符序列   (No   $   money)。紧跟在   $   之前的转义字符   (\\)   命令   vi   逐字搜索货币符号。  
  
本文出自 “博客即日起停止更新” 博客，请务必保留此出处http://sucre.blog.51cto.com/1084905/270556