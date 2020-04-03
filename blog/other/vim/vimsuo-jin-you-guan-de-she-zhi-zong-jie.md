#Vim缩进有关的设置总结  
`tabstop` 一个 **tab** 等于多少个空格，当`expandtab`的情况下，会影响在插入模式下按下 **tab** 键输入的空格，以及真正的 **\t** 用多少个空格显示；当在`noexpandtab`的情况下，只会影响 **\t** 显示多少个空格（因为插入模式下按 **tab** 将会输入一个字符 **\t** ）  
`expandtab` 设为真，在插入模式下按 **tab** 会插入空格，用 **>** 缩进也会用空格空出来；如果设置为假`noexpandtab`，那么插入模式下按 **tab** 就是输入 **\t** ，用 **>** 缩进的结果也是在行前插入 **\t**   
`softtabstop` 按下 **tab** 将补出多少个空格。在`noexpandtab`的状态下，实际补出的是 **\t** 和空格的组合。所以这个选项非常奇葩，比如此时`tabstop=4 softtabstop=6`，那么按下 **tab** 将会出现一个 **\t** 两个空格  
`shiftwidth` 使用 **>>** **<<** 或 **==** 来缩进代码的时候补出的空格数。这个值也会影响`autoindent`自动缩进的值 
 
ref: https://www.kawabangga.com/posts/2817