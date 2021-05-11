# Git 如何 clone 非 master 分支的代码

`git branch -r #查看远程分支`  
或  
`git branch -a #查看所有分支`  
会显示

```text
origin/HEAD -> origin/master
origin/daily/1.2.2
origin/daily/1.3.0
origin/daily/1.4.1
origin/develop
origin/feature/daily-1.0.0
origin/master
```

然后直接  
`git checkout origin/daily/1.4.1`

**设置已有的本地分支跟踪一个刚刚拉取下来的远程分支，或者想要修改正在跟踪的上游分支**  我们在本地先建立一个分支，建议名称和远程的想要同步的分支名称一样。

```text
git branch daily/1.4.1
```

再切换到这个本地分支

```text
git checkout daily/1.4.1
# Switched to branch 'daily/1.4.1'
```

接下来就可以去建立上游分支的关联了，但是这个命令比较长，不好记，我们可以直接先`pull`一下，`git` 会提示我们相应的操作和命令。

```text
git pull
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> daily/1.4.1
```

我们看到最后一行，执行这个命令，即可完成与上游分支的关联。

```text
git branch --set-upstream-to=origin/daily/1.4.1 daily/1.4.1
# Branch daily/1.4.1 set up to track remote branch daily/1.4.1 from origin.
```

然后再`pull`一下就好了！

```text
git pull
```

