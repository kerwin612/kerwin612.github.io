#Windows下使用Beyond Compare作为git的比对与合并工具
其实`Beyond Compare`[官网](http://www.scootersoftware.com/support.php?zz=kb_vcs#gitwindows)就有介绍 如何配置`git`的`difftool`和`mergetool`,其实就几行`git`命令。  
```
#difftool 配置
git config --global diff.tool bc4
git config --global difftool.bc4.cmd "\"c:/program files (x86)/beyond compare 4/bcomp.exe\" \"$LOCAL\" \"$REMOTE\""

#mergeftool 配置
git config --global merge.tool bc4
git config --global mergetool.bc4.cmd "\"c:/program files (x86)/beyond compare 4/bcomp.exe\" \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\""
git config --global mergetool.bc4.trustExitCode true
```  
但是我照着上面的步骤配置,使用`difftool`命令后，发现左右两边都为空白文件。研究了半天没研究出个所以然。 后来突然想起来用户目录下的`.gitconfig`看看配置情况，才发现原因。 打开配置文件看到的信息差不多是这样：
```
[diff]
tool = bc4
[difftool]
prompt = false
[difftool "bc4"]
cmd = \"c:/program files (x86)/beyond compare 4/bcomp.exe\" 

.....
```  
使用`git bash`是执行上述几个命令后，`.gitconfig`文件中并没有 `\"$LOCAL\" \"$REMOTE\"`的影子，所以使用`difftool`比对文件时，两边都是空白，因为根本就没有传参数进去。 所以换一个思路，不用命令设置，而是直接编辑`.gitconfig`文件设置，就没问题了。

`.gitconfig`文件新增如下配置并保存
```
[diff]
tool = bc4
[difftool]
prompt = false
[difftool "bc4"]
cmd = "\"c:/program files (x86)/beyond compare 4/bcomp.exe\" \"$LOCAL\" \"$REMOTE\""
[merge]
tool = bc
[mergetool]
prompt = false
[mergetool "bc4"]
cmd = "\"c:/program files (x86)/beyond compare 4/bcomp.exe\" \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\""
```
然后在`git`命令行中执行相关命令就ok啦：）
```
#比对当前文件相对于Head版本的改动
git difftool <file_name>

#当merge <branch_name>提示冲突时，执行下面命令便可以调出bc合并冲突
git mergetool
```