# git提示error setting certificate verify locations解决办法

**错误信息**

```text
git.exe pull --progress --no-rebase -v "origin"

fatal: unable to access 'https://github.com/konsumer/arduinoscope.git/': error setting certificate verify locations:
CAfile: D:\Program Files\Git\mingw64/bin/curl-ca-bundle.crt
CApath: none
```

**解决方法**

```text
git config --system http.sslcainfo "C:\Program Files (x86)\git\bin\curl-ca-bundle.crt"
```

（注意修改为正确的文件路径）或

```text
git config --system http.sslverify false
```

`git config --global core.autocrlf true`

