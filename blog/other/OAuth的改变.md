#OAuth的改变  

###OAuth1.0  
在OAuth诞生前，Web安全方面的标准协议只有OpenID，不过它关注的是验证，即WHO的问题，而不是授权，即WHAT的问题。好在FlickrAuth和GoogleAuthSub等私有协议在授权方面做了不少有益的尝试，从而为OAuth的诞生奠定了基础。

[OAuth1.0](http://oauth.net/core/1.0/)定义了三种角色：User、Service Provider、Consumer。如何理解？假设我们做了一个SNS，它有一个功能，可以让会员把他们在Google上的联系人导入到SNS上，那么此时的会员是User，Google是Service Providere，而SNS则是Consumer。
```
 +----------+                                           +----------+
 |          |--(A)- Obtaining a Request Token --------->|          |
 |          |                                           |          |
 |          |<-(B)- Request Token ----------------------|          |
 |          |       (Unauthorized)                      |          |
 |          |                                           |          |
 |          |      +--------+                           |          |
 |          |>-(C)-|       -+-(C)- Directing ---------->|          |
 |          |      |       -+-(D)- User authenticates ->|          |
 |          |      |        |      +----------+         | Service  |
 | Consumer |      | User-  |      |          |         | Provider |
 |          |      | Agent -+-(D)->|   User   |         |          |
 |          |      |        |      |          |         |          |
 |          |      |        |      +----------+         |          |
 |          |<-(E)-|       -+-(E)- Request Token ------<|          |
 |          |      +--------+      (Authorized)         |          |
 |          |                                           |          |
 |          |--(F)- Obtaining a Access Token ---------->|          |
 |          |                                           |          |
 |          |<-(G)- Access Token -----------------------|          |
 +----------+                                           +----------+
 ```
 花絮：OAuth1.0的RFC没有ASCII流程图，于是我敲了几百下键盘自己画了一个，后经网友提示，Emacs可以很轻松的搞定ASCII图：[Emacs Screencast: Artist Mode](http://www.cinsk.org/emacs/emacs-artist.html)，VIM当然也可以搞定，不过要借助一个插件：[DrawIt](http://www.vim.org/scripts/script.php?script_id=40)，可惜我的键盘都要坏了。

Consumer申请Request Token（/oauth/1.0/request_token）：
```
oauth_consumer_key
oauth_signature_method
oauth_signature
oauth_timestamp
oauth_nonce
oauth_version
```
Service Provider返回Request Token：
```
oauth_token
oauth_token_secret
```
Consumer重定向User到Service Provider（/oauth/1.0/authorize）：
```
oauth_token
oauth_callback
```
Service Provider在用户授权后重定向User到Consumer：
```
oauth_token
```
Consumer申请Access Token（/oauth/1.0/access_token）：
```
oauth_consumer_key
oauth_token
oauth_signature_method
oauth_signature
oauth_timestamp
oauth_nonce
oauth_version
```
Service Provider返回Access Token：
```
oauth_token
oauth_token_secret
```
…

注：整个操作流程中，需要注意涉及两种Token，分别是Request Token和Access Token，其中Request Token又涉及两种状态，分别是未授权和已授权。

###OAuth1.0a  
OAuth1.0存在[安全漏洞](http://oauth.net/advisories/2009-1/)，详细介绍：[Explaining the OAuth Session Fixation Attack](http://hueniverse.com/2009/04/explaining-the-oauth-session-fixation-attack/)，还有这篇：[How the OAuth Security Battle Was Won, Open Web Style](http://www.readwriteweb.com/archives/how_the_oauth_security_battle_was_won_open_web_sty.php)。

简单点来说，这是一种会话固化攻击，和常见的会话劫持攻击不同的是，在会话固化攻击中，攻击者会初始化一个合法的会话，然后诱使用户在这个会话上完成后续操作，从而达到攻击的目的。反映到OAuth1.0上，攻击者会先申请Request Token，然后诱使用户授权这个Request Token，接着针对回调地址的使用，又存在以下几种攻击手段：

* 如果Service Provider没有限制回调地址（应用设置没有限定根域名一致），那么攻击者可以把oauth_callback设置成成自己的URL，当User完成授权后，通过这个URL自然就能拿到User的Access Token。
* 如果Consumer不使用回调地址（桌面或手机程序），而是通过User手动拷贝粘贴Request Token完成授权的话，那么就存在一个竞争关系，只要攻击者在User授权后，抢在User前面发起请求，就能拿到User的Access Token。  

为了修复安全问题，[OAuth1.0a](http://oauth.net/core/1.0a/)出现了（[RFC5849](http://tools.ietf.org/html/rfc5849)），主要修改了以下细节：

* Consumer申请Request Token时，必须传递oauth_callback，而Consumer申请Access Token时，不需要传递oauth_callback。通过前置oauth_callback的传递时机，让oauth_callback参与签名，从而避免攻击者假冒oauth_callback。
* Service Provider获得User授权后重定向User到Consumer时，返回oauth_verifier，它会被用在Consumer申请Access Token的过程中。攻击者无法猜测它的值。  

Consumer申请Request Token（/oauth/1.0a/request_token）：
```
oauth_consumer_key
oauth_signature_method
oauth_signature
oauth_timestamp
oauth_nonce
oauth_version
oauth_callback
```
Service Provider返回Request Token：
```
oauth_token
oauth_token_secret
oauth_callback_confirmed
```
Consumer重定向User到Service Provider（/oauth/1.0a/authorize）：
```
oauth_token
```
Service Provider在用户授权后重定向User到Consumer：
```
oauth_token
oauth_verifier
```
Consumer申请Access Token（/oauth/1.0a/access_token）：
```
oauth_consumer_key
oauth_token
oauth_signature_method
oauth_signature
oauth_timestamp
oauth_nonce
oauth_version
oauth_verifier
```
Service Provider返回Access Token：
```
oauth_token
oauth_token_secret
```
注：Service Provider返回Request Token时，附带返回的oauth_callback_confirmed是为了说明Service Provider是否支持OAuth1.0a版本。

…

签名参数中，oauth_timestamp表示客户端发起请求的时间，如未验证会带来安全问题。

在探讨oauth_timestamp之前，先聊聊oauth_nonce，它是用来防止重放攻击的，Service Provider应该验证唯一性，不过保存所有的oauth_nonce并不现实，所以一般只保存一段时间（比如最近一小时）内的数据。

如果不验证oauth_timestamp，那么一旦攻击者拦截到某个请求后，只要等到限定时间到了，oauth_nonce再次生效后就可以把请求原样重发，签名自然也能通过，完全是一个合法请求，所以说Service Provider必须验证oauth_timestamp和系统时钟的偏差是否在可接受范围内（比如十分钟），如此才能彻底杜绝重放攻击。

…

需要单独说一下桌面或手机应用应该如何使用OAuth1.0a。此类应用通常没有服务端，无法设置Web形式的oauth_callback地址，此时应该把它设置成oob（out-of-band），当用户选择授权后，Service Provider在页面上显示PIN码（也就是oauth_verifier），并引导用户把它粘贴到应用里完成授权。

一个问题是应用如何打开用户授权页面呢？很容易想到的做法是使用内嵌浏览器，说它是个错误的做法或许有点偏激，但它至少是个对用户不友好的做法，因为一旦浏览器内嵌到程序里，那么用户输入的用户名密码就有被监听的可能；对用户友好的做法应该是打开新窗口，弹出系统默认的浏览器，让用户在可信赖的上下文环境中完成授权流程。

不过这样的方式需要用户在浏览器和应用间手动切换，才能完成授权流程，某种程度上说，影响了用户体验，好在可以通过一些其它的技巧来规避这个问题，其中一个行之有效的办法是Monitor web-browser title-bar，简单点说，操作系统一般提供相应的API可以让应用监听桌面上所有窗口的标题，应用一旦发现某个窗口标题符合预定义格式，就可以认为它是我们要的PIN码，无需用户参与就可以完成授权流程。[Google](http://code.google.com/apis/accounts/docs/OAuth2.html#IA)支持这种方式，并且有资料专门描述了细节：[Auto-Detecting Approval](https://sites.google.com/site/oauthgoog/oauth-practices/auto-detecting-approval)（注：墙！）。

还有一点需要注意的是对桌面或移动应用来说，consumer_key和consumer_secret通常都是直接保存在应用里的，所以对攻击者而言，理论上可以通过反编译之类的手段解出来。进而通过consumer_key和consumer_secret签名一个伪造的请求，并且在请求中把oauth_callback设置成自己控制的URL，来骗取用户授权。为了屏蔽此类问题，Service Provider需要强制开发者必须预定义回调地址：如果预定义的回调地址是URL方式的，则需要验证请求中的回调地址和预定义的回调地址是否主域名一致；如果预定义的回调地址是oob方式的，则禁止请求以URL的方式回调。

###OAuth2.0  
OAuth1.0虽然在安全性上经过修补已经没有问题了，但还存在其它的缺点，其中最主要的莫过于以下两点：其一，签名逻辑过于复杂，对开发者不够友好；其二，授权流程太过单一，除了Web应用以外，对桌面、移动应用来说不够友好。

为了弥补这些短板，[OAuth2.0](http://tools.ietf.org/html/draft-ietf-oauth-v2)做了以下改变：

首先，去掉签名，改用SSL（HTTPS）确保安全性，所有的token不再有对应的secret存在，这也直接导致OAuth2.0不兼容老版本。

其次，针对不同的情况使用不同的授权流程，和老版本只有一种授权流程相比，新版本提供了四种授权流程，可依据客观情况选择。

在详细说明授权流程之前，我们需要先了解一下OAuth2.0中的角色：

OAuth1.0定义了三种角色：User、Service Provider、Consumer。而OAuth2.0则定义了四种角色：Resource Owner、Resource Server、Client、Authorization Server：

* Resource Owner：User
* Resource Server：Service Provider
* Client：Consumer
* Authorization Server：Service Provider  

也就是说，OAuth2.0把原本OAuth1.0里的Service Provider角色分拆成Resource Server和Authorization Server两个角色，在授权时交互的是Authorization Server，在请求资源时交互的是Resource Server，当然，有时候他们是合二为一的。

下面我们具体介绍一下OAuth2.0提供的四种授权流程：

#####Authorization Code

可用范围：此类型可用于有服务端的应用，是最贴近老版本的方式。
```
 +----------+
 | resource |
 |   owner  |
 |          |
 +----------+
      ^
      |
     (B)
 +----|-----+          Client Identifier      +---------------+
 |         -+----(A)-- & Redirection URI ---->|               |
 |  User-   |                                 | Authorization |
 |  Agent  -+----(B)-- User authenticates --->|     Server    |
 |          |                                 |               |
 |         -+----(C)-- Authorization Code ---<|               |
 +-|----|---+                                 +---------------+
   |    |                                         ^      v
  (A)  (C)                                        |      |
   |    |                                         |      |
   ^    v                                         |      |
 +---------+                                      |      |
 |         |>---(D)-- Authorization Code ---------'      |
 |  Client |          & Redirection URI                  |
 |         |                                             |
 |         |<---(E)----- Access Token -------------------'
 +---------+       (w/ Optional Refresh Token)
```
Client向Authorization Server发出申请（/oauth/2.0/authorize）：
```
response_type = code
client_id
redirect_uri
scope
state
```
Authorization Server在Resource Owner授权后给Client返回Authorization Code：
```
code
state
```
Client向Authorization Server发出申请（/oauth/2.0/token）：
```
grant_type = authorization_code
code
client_id
client_secret
redirect_uri
```
Authorization Server在Resource Owner授权后给Client返回Access Token：
```
access_token
token_type
expires_in
refresh_token
```
说明：基本流程就是拿Authorization Code换Access Token。

#####Implicit Grant

可用范围：此类型可用于没有服务端的应用，比如Javascript应用。
```
 +----------+
 | Resource |
 |  Owner   |
 |          |
 +----------+
      ^
      |
     (B)
 +----|-----+          Client Identifier     +---------------+
 |         -+----(A)-- & Redirection URI --->|               |
 |  User-   |                                | Authorization |
 |  Agent  -|----(B)-- User authenticates -->|     Server    |
 |          |                                |               |
 |          |<---(C)--- Redirection URI ----<|               |
 |          |          with Access Token     +---------------+
 |          |            in Fragment
 |          |                                +---------------+
 |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
 |          |          without Fragment      |     Client    |
 |          |                                |    Resource   |
 |     (F)  |<---(E)------- Script ---------<|               |
 |          |                                +---------------+
 +-|--------+
   |    |
  (A)  (G) Access Token
   |    |
   ^    v
 +---------+
 |         |
 |  Client |
 |         |
 +---------+
```
Client向Authorization Server发出申请（/oauth/2.0/authorize）：
```
response_type = token
client_id
redirect_uri
scope
state
```
Authorization Server在Resource Owner授权后给Client返回Access Token：
```
access_token
token_type
expires_in
scope
state
```
说明：没有服务端的应用，其信息只能保存在客户端，如果使用Authorization Code授权方式的话，无法保证client_secret的安全。BTW：不返回Refresh Token。

#####Resource Owner Password Credentials

可用范围：不管有无服务端，此类型都可用。
```
 +----------+
 | Resource |
 |  Owner   |
 |          |
 +----------+
      v
      |    Resource Owner
     (A) Password Credentials
      |
      v
 +---------+                                  +---------------+
 |         |>--(B)---- Resource Owner ------->|               |
 |         |         Password Credentials     | Authorization |
 | Client  |                                  |     Server    |
 |         |<--(C)---- Access Token ---------<|               |
 |         |    (w/ Optional Refresh Token)   |               |
 +---------+                                  +---------------+
```
Clien向Authorization Server发出申请（/oauth/2.0/token）：
```
grant_type = password
username
password
scope
```
AuthorizationServer给Client返回AccessToken：
```
access_token
token_type
expires_in
refresh_token
```
说明：因为涉及用户名和密码，所以此授权类型仅适用于可信赖的应用。

#####Client Credentials

可用范围：不管有无服务端，此类型都可用。
```
 +---------+                                  +---------------+
 |         |                                  |               |
 |         |>--(A)- Client Authentication --->| Authorization |
 | Client  |                                  |     Server    |
 |         |<--(B)---- Access Token ---------<|               |
 |         |                                  |               |
 +---------+                                  +---------------+
```
Client向Authorization Server发出申请（/oauth/2.0/token）：
```
grant_type = client_credentials
client_id
client_secret
scope
```
Authorization Server给Client返回Access Token：
```
access_token
token_type
expires_in
```
说明：此授权类型仅适用于获取与用户无关的公共信息。BTW：不返回Refresh Token。

…

流程中涉及两种Token，分别是Access Token和Refresh Token。通常，Access Token的有效期比较短，而Refresh Token的有效期比较长，如此一来，当Access Token失效的时候，就需要用Refresh Token刷新出有效的Access Token：
```
 +--------+                                         +---------------+
 |        |--(A)------- Authorization Grant ------->|               |
 |        |                                         |               |
 |        |<-(B)----------- Access Token -----------|               |
 |        |               & Refresh Token           |               |
 |        |                                         |               |
 |        |                            +----------+ |               |
 |        |--(C)---- Access Token ---->|          | |               |
 |        |                            |          | |               |
 |        |<-(D)- Protected Resource --| Resource | | Authorization |
 | Client |                            |  Server  | |     Server    |
 |        |--(E)---- Access Token ---->|          | |               |
 |        |                            |          | |               |
 |        |<-(F)- Invalid Token Error -|          | |               |
 |        |                            +----------+ |               |
 |        |                                         |               |
 |        |--(G)----------- Refresh Token --------->|               |
 |        |                                         |               |
 |        |<-(H)----------- Access Token -----------|               |
 +--------+           & Optional Refresh Token      +---------------+
```
Client向Authorization Server发出申请（/oauth/2.0/token）：
```
grant_type = refresh_token
refresh_token
client_id
client_secret
scope
```
Authorization Server给Client返回Access Token：
```
access_token
expires_in
refresh_token
scope
```
…

不过并不是所有人都对OAuth2.0投赞成票，有空可以看看：[OAuth 2.0对Web有害吗？](http://www.infoq.com/cn/news/2010/09/oauth2-bad-for-web)  

转：https://huoding.com/2011/11/08/126