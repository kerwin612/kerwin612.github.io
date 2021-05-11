# 让你提升命令行效率的 Bash 快捷键 \[完整版\]

生活在 Bash shell 中，熟记以下快捷键，将极大的提高你的命令行操作效率。

### 编辑命令

* `Ctrl + a`：移到命令行首
* `Ctrl + e`：移到命令行尾
* `Ctrl + f`：按字符前移（右向）
* `Ctrl + b`：按字符后移（左向）
* `Alt + f`：按单词前移（右向）
* `Alt + b`：按单词后移（左向）
* `Ctrl + xx`：在命令行首和光标之间移动
* `Ctrl + u`：从光标处删除至命令行首
* `Ctrl + k`：从光标处删除至命令行尾
* `Ctrl + w`：从光标处删除至字首
* `Alt + d`：从光标处删除至字尾
* `Ctrl + d`：删除光标处的字符
* `Ctrl + h`：删除光标前的字符
* `Ctrl + y`：粘贴至光标后
* `Alt + c`：从光标处更改为首字母大写的单词
* `Alt + u`：从光标处更改为全部大写的单词
* `Alt + l`：从光标处更改为全部小写的单词
* `Ctrl + t`：交换光标处和之前的字符
* `Alt + t`：交换光标处和之前的单词
* `Alt + Backspace`：与 `Ctrl + w` ~~相同~~类似，分隔符有些差别 \[感谢 rezilla 指正\]   

### 重新执行命令

* `Ctrl + r`：逆向搜索命令历史
* `Ctrl + g`：从历史搜索模式退出
* `Ctrl + p`：历史中的上一条命令
* `Ctrl + n`：历史中的下一条命令
* `Alt + .`：使用上一条命令的最后一个参数

### 控制命令

* `Ctrl + l`：清屏
* `Ctrl + o`：执行当前命令，并选择上一条命令
* `Ctrl + s`：阻止屏幕输出
* `Ctrl + q`：允许屏幕输出
* `Ctrl + c`：终止命令
* `Ctrl + z`：挂起命令
  * `Ctrl + z`可以将一个正在前台执行的命令放到后台，并且暂停
  * `&`这个用在一个命令的最后，可以把这个命令放到后台执行
  * `jobs`查看当前有多少在后台运行的命令
  * `fg %N`将后台中的命令调至前台继续运行
  * `bg %N`将一个在后台暂停的命令，变成继续执行
  * 默认`bg`，`fg`不带`%N`时表示对最后一个进程操作！`%N`是通过`jobs`命令查到的后台正在执行的命令的序号

### Bang \(!\) 命令

* `!!`：执行上一条命令
* `!blah`：执行最近的以 blah 开头的命令，如 `!ls`
* `!blah:p`：仅打印输出，而不执行
* `!$`：上一条命令的最后一个参数，与 `Alt + .` 相同
* `!$:p`：打印输出 `!$` 的内容
* `!*`：上一条命令的所有参数
* `!*:p`：打印输出 `!*` 的内容
* `^blah`：删除上一条命令中的 blah
* `^blah^foo`：将上一条命令中的 blah 替换为 foo
* `^blah^foo^`：将上一条命令中所有的 blah 都替换为 foo    

### _友情提示_：

以上介绍的大多数 `Bash` 快捷键仅当在 `emacs` 编辑模式时有效，若你将 `Bash` 配置为 `vi` 编辑模式，那将遵循 `vi` 的按键绑定。`Bash` 默认为 `emacs` 编辑模式。如果你的 `Bash` 不在 `emacs` 编辑模式，可通过 `set -o emacs` 设置。

^S、^Q、^C、^Z 是由终端设备处理的，可用 `stty` 命令设置。

{ [via](http://wp.me/pj13n-jo) }

## 把Bash设置成Vi/Vim模式

1. 设置:`set -o vi`   
2. 使用方法:   
   * 进入vi command mode  

     ```text
       Esc或Ctrl+[
     ```

   * 热键   

     ```text
       #显示所有补全
       Tab或Ctrl+i
       #下一个补全
       Ctrl+n
       #上一个补全
       Ctrl+p
       #搜索历史
       Ctrl+r
     ```

   * 设置热键  

     ```text
       #清屏
       bind -m vi-insert '\c-l':clear-screen
       #进入vi命令模式
       bind -m vi-insert '\c-x':vi-movement-mode
       #跳到末尾
       bind -m vi-insert '\c-e':end-of-line
       #跳到开头
       bind -m vi-insert '\c-a':beginning-of-line
       #向后一个字符
       bind -m vi-insert '\c-b':backward-char
       #向前一个字符
       bind -m vi-insert '\c-f':forward-char
     ```

## 常用alias

以下bash中别名设置我还并没有完全使用，也是个人觉得非常有用的（多了记起来也麻烦），所以收集在一起，习惯就好。

`/etc/profile.d/alias.sh`：

```text
alias wl='ll | wc -l'
alias l='ls -l'
alias lh='ls -lh'
alias grep='grep -i --color' #用颜色标识，更醒目；忽略大小写
alias vi=vim
alias c='clear'  # 快速清屏
alias p='pwd'
# 进入目录并列出文件，如 cdl ../conf.d/
cdl() { cd "$@" && pwd ; ls -alF; }
alias ..="cdl .."
alias ...="cd ../.."   # 快速进入上上层目录
alias .3="cd ../../.." 
alias cd..='cdl ..'
# alias cp="cp -iv"      # interactive, verbose
alias rm="rm -i"      # interactive
# alias mv="mv -iv"       # interactive, verbose
alias psg='\ps aux | grep -v grep | grep --color' # 查看进程信息
alias hg='history|grep'
alias netp='netstat -tulanp'  # 查看服务器端口连接信息
alias lvim="vim -c \"normal '0\""  # 编辑vim最近打开的文件
alias tf='tail -f '  # 快速查看文件末尾输出
# 自动在文件末尾加上 .bak-日期 来备份文件，如 bu nginx.conf
bak() { cp "$@" "$@.bak"-`date +%y%m%d`; echo "`date +%Y-%m-%d` backed up $PWD/$@"; }
# 级联创建目录并进入，如 mcd a/b/c
mcd() { mkdir -p $1 && cd $1 && pwd ; }
# 查看去掉#注释和空行的配置文件，如 nocomm /etc/squid/squid.conf
alias nocomm='grep -Ev '\''^(#|$)'\'''
# 快速根据进程号pid杀死进程，如 psid tomcat， 然后 kill9 两个tab键提示要kill的进程号
alias kill9='kill -9';
psid() {
  [[ ! -n ${1} ]] && return;   # bail if no argument
  pro="[${1:0:1}]${1:1}";      # process-name –> [p]rocess-name (makes grep better)
  ps axo pid,user,command | grep -v grep |grep -i --color ${pro};   # show matching processes
  pids="$(ps axo pid,user,command | grep -v grep | grep -i ${pro} | awk '{print $1}')";   # get pids
  complete -W "${pids}" kill9     # make a completion list for kk
}
# 解压所有归档文件工具
function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
 else
    if [ -f $1 ] ; then
        # NAME=${1%.*}
        # mkdir $NAME && cd $NAME
        case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xvJf $1    ;;
          *.lzma)      unlzma $1      ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x -ad $1 ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.xz)        unxz $1        ;;
          *.exe)       cabextract $1  ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}
# 其它你自己的命令
alias nginxreload='sudo /usr/local/nginx/sbin/nginx -s reload'
```

要去掉别名，请用`unalias aliasname`，或者临时执行不用别名，执行原始命令`\alias`。

