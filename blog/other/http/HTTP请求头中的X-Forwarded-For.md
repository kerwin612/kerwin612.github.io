#HTTP请求头中的X-Forwarded-For

我一直认为，对于从事 Web 前端开发的同学来说，HTTP 协议以及其他常见的网络知识属于必备项。一方面，前端很多工作如 Web 性能优化，大部分规则都跟 HTTP、HTTPS、SPDY 和 TCP 等协议的特点直接对应，如果不从协议本身出发而是一味地照办教条，很可能适得其反。另一方面，随着 Node.js 的发展壮大，越来越多的前端同学开始写服务端程序，甚至是服务端框架（[ThinkJS](http://thinkjs.org/) 就是这样由前端工程师开发，并有着众多前端工程师用户的 Node.js 框架），掌握必要的网络知识，对于服务端程序安全、部署、运维等工作来说至关重要。
我的博客有一个「[HTTP 相关](https://imququ.com/series.html#toc-7)」专题，今后会陆续更新更多内容进去，欢迎关注。今天要说的是 HTTP 请求头中的 `X-Forwarded-For`（**XFF**）。

##背景
通过名字就知道，`X-Forwarded-For` 是一个 HTTP 扩展头部。`HTTP/1.1`（RFC 2616）协议并没有对它的定义，它最开始是由 `Squid` 这个缓存代理软件引入，用来表示 HTTP 请求端真实 IP。如今它已经成为事实上的标准，被各大 HTTP 代理、负载均衡等转发服务广泛使用，并被写入 [RFC 7239](http://tools.ietf.org/html/rfc7239)（Forwarded HTTP Extension）标准之中。
`X-Forwarded-For` 请求头格式非常简单，就这样：
```
X-Forwarded-For: client, proxy1, proxy2
```
可以看到，XFF 的内容由「英文逗号 + 空格」隔开的多个部分组成，最开始的是离服务端最远的设备 IP，然后是每一级代理设备的 IP。
如果一个 HTTP 请求到达服务器之前，经过了三个代理 Proxy1、Proxy2、Proxy3，IP 分别为 IP1、IP2、IP3，用户真实 IP 为 IP0，那么按照 XFF 标准，服务端最终会收到以下信息：
```
X-Forwarded-For: IP0, IP1, IP2
```
Proxy3 直连服务器，它会给 XFF 追加 IP2，表示它是在帮 Proxy2 转发请求。列表中并没有 IP3，IP3 可以在服务端通过 `Remote Address` 字段获得。*我们知道 HTTP 连接基于 TCP 连接，HTTP 协议中没有 IP 的概念，Remote Address 来自 TCP 连接，表示与服务端建立 TCP 连接的设备 IP*，在这个例子里就是 IP3。
*Remote Address 无法伪造，因为建立 TCP 连接需要三次握手，如果伪造了源 IP，无法建立 TCP 连接，更不会有后面的 HTTP 请求*。不同语言获取 Remote Address 的方式不一样，例如 php 是 `$_SERVER["REMOTE_ADDR"]`，Node.js 是 `req.connection.remoteAddress`，但原理都一样。

##问题
有了上面的背景知识，开始说问题。我用 Node.js 写了一个最简单的 Web Server 用于测试。HTTP 协议跟语言无关，这里用 Node.js 只是为了方便演示，换成任何其他语言都可以得到相同结论。另外本文用 Nginx 也是一样的道理，如果有兴趣，换成 Apache 或其他 Web Server 也一样。
下面这段代码会监听 9009 端口，并在收到 HTTP 请求后，输出一些信息：
```js
var http = require('http');

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.write('remoteAddress: ' + req.connection.remoteAddress + '\n');
    res.write('x-forwarded-for: ' + req.headers['x-forwarded-for'] + '\n');
    res.write('x-real-ip: ' + req.headers['x-real-ip'] + '\n');
    res.end();
}).listen(9009, '0.0.0.0');
```
这段代码除了前面介绍过的 `Remote Address` 和 `X-Forwarded-For`，还有一个 X-Real-IP，这又是一个自定义头部字段。X-Real-IP 通常被 HTTP 代理用来表示与它产生 TCP 连接的设备 IP，这个设备可能是其他代理，也可能是真正的请求端。需要注意的是，X-Real-IP 目前并不属于任何标准，代理和 Web 应用之间可以约定用任何自定义头来传递这个信息。
现在可以用域名 + 端口号直接访问这个 Node.js 服务，再配一个 Nginx 反向代理：
```
location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;

    proxy_pass http://127.0.0.1:9009/;
    proxy_redirect off;
}
```
我的 Nginx 监听 80 端口，所以不带端口就可以访问 Nginx 转发过的服务。
测试直接访问 Node 服务：
```bash
curl http://t1.imququ.com:9009/

remoteAddress: 114.248.238.236
x-forwarded-for: undefined
x-real-ip: undefined
```
由于我的电脑直接连接了 Node.js 服务，`Remote Address` 就是我的 IP。同时我并未指定额外的自定义头，所以后两个字段都是 undefined。
再来访问 Nginx 转发过的服务：
```bash
curl http://t1.imququ.com/

remoteAddress: 127.0.0.1
x-forwarded-for: 114.248.238.236
x-real-ip: 114.248.238.236
```
这一次，我的电脑是通过 Nginx 访问 Node.js 服务，得到的 `Remote Address` 实际上是 Nginx 的本地 IP。而前面 Nginx 配置中的这两行起作用了，为请求额外增加了两个自定义头：
```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```
实际上，在生产环境中部署 Web 应用，一般都采用上面第二种方式，有很多好处。但这就引入一个隐患：很多 Web 应用为了获取用户真正的 IP，从 HTTP 请求头中获取 IP。
HTTP 请求头可以随意构造，我们通过 `curl` 的 -H 参数构造 `X-Forwarded-For` 和 X-Real-IP，再来测试一把。
直接访问 Node.js 服务：
```bash
curl http://t1.imququ.com:9009/ -H 'X-Forwarded-For: 1.1.1.1' -H 'X-Real-IP: 2.2.2.2'

remoteAddress: 114.248.238.236
x-forwarded-for: 1.1.1.1
x-real-ip: 2.2.2.2
```
对于 Web 应用来说，`X-Forwarded-For` 和 X-Real-IP 就是两个普通的请求头，自然就不做任何处理原样输出了。这说明，对于直连部署方式，除了从 TCP 连接中得到的 `Remote Address` 之外，请求头中携带的 IP 信息都不能信。
访问 Nginx 转发过的服务：
```bash
curl http://t1.imququ.com/ -H 'X-Forwarded-For: 1.1.1.1' -H 'X-Real-IP: 2.2.2.2'

remoteAddress: 127.0.0.1
x-forwarded-for: 1.1.1.1, 114.248.238.236
x-real-ip: 114.248.238.236
```
这一次，Nginx 会在 `X-Forwarded-For` 后追加我的 IP；并用我的 IP 覆盖 X-Real-IP 请求头。这说明，有了 Nginx 的加工，`X-Forwarded-For` 最后一节以及 X-Real-IP 整个内容无法构造，可以用于获取用户 IP。
用户 IP 往往会被使用与跟 Web 安全有关的场景上，例如检查用户登录地区，基于 IP 做访问频率控制等等。这种场景下，确保 IP 无法构造更重要。经过前面的测试和分析，对于直接面向用户部署的 Web 应用，必须使用从 TCP 连接中得到的 `Remote Address`；对于部署了 Nginx 这样反向代理的 Web 应用，在正确配置了 Set Header 行为后，可以使用 Nginx 传过来的 X-Real-IP 或 `X-Forwarded-For` 最后一节（实际上它们一定等价）。
那么，Web 应用自身如何判断请求是直接过来，还是由可控的代理转发来的呢？在代理转发时增加额外的请求头是一个办法，但是不怎么保险，因为请求头太容易构造了。如果一定要这么用，这个自定义头要够长够罕见，还要保管好不能泄露出去。
判断 `Remote Address` 是不是本地 IP 也是一种办法，不过也不完善，因为在 Nginx 所处服务器上访问，无论直连还是走 Nginx 代理，`Remote Address` 都是 127.0.0.1。这个问题还好通常可以忽略，更麻烦的是，反向代理服务器和实际的 Web 应用不一定部署在同一台服务器上。所以更合理的做法是收集所有代理服务器 IP 列表，Web 应用拿到 `Remote Address` 后逐一比对来判断是以何种方式访问。
通常，为了简化逻辑，生产环境会封掉通过带端口直接访问 Web 应用的形式，只允许通过 Nginx 来访问。那是不是这样就没问题了呢？也不见得。
首先，如果用户真的是通过代理访问 Nginx，`X-Forwarded-For` 最后一节以及 X-Real-IP 得到的是代理的 IP，安全相关的场景只能用这个，但有些场景如根据 IP 显示所在地天气，就需要尽可能获得用户真实 IP，这时候 `X-Forwarded-For` 中第一个 IP 就可以排上用场了。这时候需要注意一个问题，还是拿之前的例子做测试：
```bash
curl http://t1.imququ.com/ -H 'X-Forwarded-For: unknown, <>"1.1.1.1'

remoteAddress: 127.0.0.1
x-forwarded-for: unknown, <>"1.1.1.1, 114.248.238.236
x-real-ip: 114.248.238.236
```
`X-Forwarded-For` 最后一节是 Nginx 追加上去的，但之前部分都来自于 Nginx 收到的请求头，这部分用户输入内容完全不可信。*使用时需要格外小心，符合 IP 格式才能使用，不然容易引发 SQL 注入或 XSS 等安全漏洞。*

##结论
直接对外提供服务的 Web 应用，在进行与安全有关的操作时，只能通过 `Remote Address` 获取 IP，不能相信任何请求头；
使用 Nginx 等 Web Server 进行反向代理的 Web 应用，在配置正确的前提下，要用 `X-Forwarded-For` 最后一节 或 X-Real-IP 来获取 IP（因为 `Remote Address` 得到的是 Nginx 所在服务器的内网 IP）；同时还应该禁止 Web 应用直接对外提供服务；
在与安全无关的场景，例如通过 IP 显示所在地天气，可以从 `X-Forwarded-For` 靠前的位置获取 IP，但是需要校验 IP 格式合法性；
PS：网上有些文章建议这样配置 Nginx，其实并不合理：
```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $remote_addr;
```
这样配置之后，安全性确实提高了，但是也导致请求到达 Nginx 之前的所有代理信息都被抹掉，无法为真正使用代理的用户提供更好的服务。还是应该弄明白这中间的原理，具体场景具体分析。
转：https://imququ.com/post/x-forwarded-for-header-in-http.html

