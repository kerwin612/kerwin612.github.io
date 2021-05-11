# JVM上的随机数与熵池策略

在apache-tomcat官方文档：[如何让tomcat启动更快](http://wiki.apache.org/tomcat/HowTo/FasterStartUp) 里面提到了一些启动时的优化项，其中一项是关于随机数生成时，采用的“熵源”\(entropy source\)的策略。  
他提到tomcat7的session id的生成主要通过`java.security.SecureRandom`生成随机数来实现，随机数算法使用的是”**SHA1PRNG**”

```java
private String secureRandomAlgorithm = "SHA1PRNG";
```

在sun/oracle的jdk里，这个算法的提供者在底层依赖到操作系统提供的随机数据，在linux上，与之相关的是_**/dev/random**_和_**/dev/urandom**_，对于这两个设备块的描述以前也见过讨论随机数的文章，wiki中有比较详细的描述，摘抄过来，先看/dev/random:

> 在读取时，/dev/random设备会返回小于熵池噪声总数的随机字节。/dev/random可生成高随机性的公钥或一次性密码本。若熵池空了，对/dev/random的读操作将会被阻塞，直到收集到了足够的环境噪声为止

而 /dev/urandom 则是一个非阻塞的发生器:

> dev/random的一个副本是/dev/urandom （”unlocked”，非阻塞的随机数发生器），它会重复使用熵池中的数据以产生伪随机数据。这表示对/dev/urandom的读取操作不会产生阻塞，但其输出的熵可能小于/dev/random的。它可以作为生成较低强度密码的伪随机数生成器，不建议用于生成高强度长期密码。

另外wiki里也提到了为什么linux内核里的随机数生成器采用SHA1散列算法而非加密算法，是为了避开法律风险\(密码出口限制\)。

回到tomcat文档里的建议，采用非阻塞的熵源\(entropy source\)，通过java系统属性来设置：

```java
-Djava.security.egd=file:/dev/./urandom
```

这个系统属性_**egd**_表示熵收集守护进程\(_entropy gathering daemon_\)，但这里值为何要在dev和random之间加一个点呢？是因为一个 [jdk的bug](http://bugs.java.com/bugdatabase/view_bug.do?bug_id=6202721) ，在这个bug的连接里有人反馈及时对 securerandom.source 设置为 /dev/urandom 它也仍然使用的 /dev/random，有人提供了变通的解决方法，其中一个变通的做法是对securerandom.source设置为 /dev/./urandom 才行。也有人评论说这个不是bug，是有意为之。

我看了一下我当前所用的jdk7的java.security文件里，配置里仍使用的是/dev/urandom：

```bash
#
# Select the source of seed data for SecureRandom. By default an
# attempt is made to use the entropy gathering device specified by
# the securerandom.source property. If an exception occurs when
# accessing the URL then the traditional system/thread activity
# algorithm is used.
#
# On Solaris and Linux systems, if file:/dev/urandom is specified and it
# exists, a special SecureRandom implementation is activated by default.
# This "NativePRNG" reads random bytes directly from /dev/urandom.
#
# On Windows systems, the URLs file:/dev/random and file:/dev/urandom
# enables use of the Microsoft CryptoAPI seed functionality.
#
securerandom.source=file:/dev/urandom
```

我不确定jdk7里，这个 /dev/urandom 也同那个bug报告里所说的等同于 /dev/random；要使用非阻塞的熵池，这里还是要修改为/dev/./urandom 呢，还是jdk7已经修复了这个问题，就是同注释里的意思，只好验证一下。

使用bug报告里给出的代码：

```java
import java.security.SecureRandom;
class JRand {
    public static void main(String args[]) throws Exception {
        System.out.println("Ok: " +
            SecureRandom.getInstance("SHA1PRNG").nextLong());
    }
}
```

然后设置不同的系统属性来验证，先是在我的mac上：

```bash
% time java -Djava.security.egd=file:/dev/urandom  JRand
Ok: 8609191756834777000
java -Djava.security.egd=file:/dev/urandom JRand  
0.11s user 0.03s system 115% cpu 0.117 total

% time java -Djava.security.egd=file:/dev/./urandom  JRand
Ok: -3573266464480299009
java -Djava.security.egd=file:/dev/./urandom JRand  
0.11s user 0.03s system 116% cpu 0.116 total
```

可以看到/dev/urandom和 /dev/./urandom 的执行时间差不多，有点纳闷，再仔细看一下wiki里说的：

> FreeBSD操作系统实现了256位的Yarrow算法变体，以提供伪随机数流。与Linux的/dev/random不同，FreeBSD的/dev/random不会产生阻塞，与Linux的/dev/urandom相似，提供了密码学安全的伪随机数发生器，而不是基于熵池。而FreeBSD的/dev/urandom则只是简单的链接到了/dev/random。

尽管在我的mac上/dev/urandom并不是/dev/random的链接，但mac与bsd内核应该是相近的，/dev/random也是非阻塞的，/dev/urandom是用来兼容linux系统的，这两个随机数生成器的行为是一致的。参考[这里](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man4/random.4.html)。

然后再到一台ubuntu系统上测试：

```bash
% time java -Djava.security.egd=file:/dev/urandom  JRand
Ok: 6677107889555365492
java -Djava.security.egd=file:/dev/urandom JRand  
0.14s user 0.02s system 9% cpu 1.661 total

% time java -Djava.security.egd=file:/dev/./urandom  JRand
Ok: 5008413661952823775
java -Djava.security.egd=file:/dev/./urandom JRand  
0.12s user 0.02s system 99% cpu 0.145 total
```

这回差异就完全体现出来了，阻塞模式的熵池耗时用了1.6秒，而非阻塞模式则只用了0.14秒，差了一个数量级，当然代价是转换为对cpu的开销了。

// 补充，连续在ubuntu上测试几次/dev/random方式之后，导致熵池被用空，被阻塞了60秒左右。应用服务器端要避免这种方式。

`export JAVA_OPTS='-Xms1024m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=1024m -Duser.timezone=GMT+08 -Djava.security.egd=file:/dev/./urandom'`

