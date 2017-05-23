#Shiro-Authorization(授权)
##Authorization
授权,也叫访问控制,即在应用中控制控制谁能访问那些资源(比如访问页面,编辑数据等).在授权中,有几个关键的对象需要了解:**主体**(`Subject`)、**资源**(`Resources`)、**权限**(`Permission`)、**角色**(`Role`).  
**主体**:即访问应用的用户,在shiro中使用Subject代表主体,用户只有在授权之后才能访问相应的资源.   
**资源**:在应用中用户可以访问、操作的任何东西都可以称作为资源(某个页面,按钮等),用户只有授权之后才能访问.  
**权限**:安全策略中的原子授权单位,通过权限可以表示用户在应用中有没有操作某个资源的权利.Tips：权限仅仅反映了用户在某个资源上的操作允不允许,不反应谁去执行此操作,权限赋予给用户这个操作Shiro并不关心,而是需要应用系统自己去实现。Shiro支持**粗粒度权限**和**细粒度权限**,后续在深入.  
**角色**:角色代表了操作集合,也就是权限的集合,大部分情况下我们会赋予用户角色而不是权限,这样用户可以拥有某个角色的一组权限,管理方便。不同的角色拥有一组不同的权限。  
**隐式角色**:角色作为一个隐式的构造,你的应用程序仅仅基于一个角色就蕴含了一组行为(即权限),在软件级别上没有”角色A允许执行操作A,B,C”.直接通过角色来验证用户有没有操作权限,粒度是以角色为单位进行访问控制(**RBAC** :Role Based Acess Control,**基于角色的访问控制**),粒度较粗,如果权限规则调整则可能造成多处代码修改。  
####DEMO：
```java
//项目经理操作
if(user.hasRole("项目经理")){
    //do something
}
//权限调整,设计经理也可以操作,则必须修改此处,或者更多出的代码
if(user.hasRole("项目经理")||user.hasRole("设计经理")){
    //do something
}
```
显然这种方式做权限控制是不合理的,因为角色拥有的权限根据企业的需要可能动态的进行调整,此处以角色为单位控制权限的访问(硬编码)完全无法适应。一个解决方法就是:  
**判断某角色是否具有某种权限不能写死在代码中,应该是根据数据库读取来完成,角色聚合一组权限集合**,以资源为单位。这就是**RBAC**新解(Resources Based Acess Control:**基于资源的访问控制**)  
**显示角色**:程序中通过权限控制谁能访问某个资源,角色聚合一组权限集合(对应资源),应用可以很明确的知道该角色有哪些权限,这样假设某个角色不能访问某个资源时,只需要从权限集合中移除即可,无需修改任何代码,粒度是以资源为单位的,粒度较细,推荐方式。如下图:  
[1]   
对应我们在编写权限代码的时候例子如下:
```velocity
#if(shiro.hasPermission("user:create"))
<a id="create">新建</a>
#end
```
上面代码是velocity中对于shiro的应用,意思是用户是否拥有创建用户的权利,有则显示创建按钮,反之则不显示.以user: create资源为单位控制访问,将应用系统资源、角色以及角色和资源的关系(权限规则)剥离出来,粒度细,而且通过改变用户和角色的关系,角色的权限集合实现动态灵活的授权.  
Shiro既支持隐式方式粗粒度的授权,也支持显示方式细粒度的授权.不过更提倡的是显示角色即基于资源的访问控制.    

##授权方式
Shiro支持三种方式的授权:
#####编程式
通过代码可以实现授权
```java
Subject sub  = SecurityUtils.getSubject();
if(sub.hasRole("admin")){
    //do something
}
sub.isPermitted("user:create")  //是否具有创建用户的权利
```
#####注解式
Shiro可以通过注解完成授权,没有权限将抛出相应的异常,不过需要在你的应用程序中启用AOP支持
```java
@RequiresRoles("admin")
public void createUser(){
}
@RequiresPermissions("user:create")
public void createUser(){
}
```
#####标签式
shiro也提供页面标签简化前端的代码.以jsp为例子:
```jsp
<shiro:hasRole name="admin">
    <a>创建</a>
</shiro:hasRole>
```
##授权
下面根据上面的两种权限控制方式，来看看shiro到底是如何进行授权的.
#####基于角色的访问控制(隐式角色)
ini配置文件
```ini
[users]
#用户名及其对应的密码和角色
L.Tao=LCore,role1,role2
Kiritor=LCore,role1
```
Tips: shiro不负责维护用户-角色信息,需要应用提供,shiro只是提供相应的接口方便验证,这里我们先写死,后续会介绍如何动态获取用户角色(数据库)
测试用例
先做一个初始化shiro的方法
```java
@Before
public void init() {
    // 1、通过ini文件获取securityManager工厂
    Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro.ini");
    // 2、得到securityManager实例,绑定SecurityUtils
    SecurityManager manager = factory.getInstance();
    SecurityUtils.setSecurityManager(manager);
}
```
以L.Tao/LCore 用户做测试,测试代码如下:
```java
@Test
public void test1() {
	// 1、得到Subject及创建用户名/密码身份验证Token（即用户身份/凭证）
	Subject subject = SecurityUtils.getSubject();
	UsernamePasswordToken token = new UsernamePasswordToken("L.Tao", "LCore");
	try {
		// 2、登录，即身份验证,委托给securityManager
		subject.login(token);
	} catch (AuthenticationException e) {
		// 3、身份验证失败
		e.printStackTrace();
	}
	Assert.assertEquals(true, subject.isAuthenticated()); // 断言用户已经登录
	System.out.println(subject.hasRole("role1"));
	System.out.println(subject.hasRole("role2"));
	List<String> list = new ArrayList<String>();
	list.add("role1");
	list.add("role2");
	for(Boolean temp:subject.hasRoles(list)){
	   System.out.println(temp);	
	}
	System.out.println(subject.hasAllRoles(list));
	// 4、退出:任何现有的session会清空
	subject.logout();
}
```
输出结果为:
```
true
true
true
true
true
```
修改上述的用户信息,以Kiritor/LCore测试,输出结果为;
```
true
false
true
false
false
```
Shiro提供了`hasRole/hasRoles/hasAllRoles`用于判断用户是否拥有某个(些)角色;shiro还提供`checkRole/checkRoles`方法,不同的是当判断为假的时候,会抛出`UnauthorizedException`异常.
#####基于资源的访问控制(显示角色)
ini配置文件如下:
```ini
[users]
#用户名及其对应的密码和角色
L.Tao=LCore,role1,role2
Kiritor=LCore,role1
[roles]
role1=user:create,user:update
role2=user:create,user:delete
```
同样的Shiro也不维护权限信息,shiro只是提供相应的接口方便验证
测试代码:
```java
@Test
public void test2() {
	// 1、得到Subject及创建用户名/密码身份验证Token（即用户身份/凭证）
	Subject subject = SecurityUtils.getSubject();
	UsernamePasswordToken token = new UsernamePasswordToken("L.Tao", "LCore");
	try {
		// 2、登录，即身份验证,委托给securityManager
		subject.login(token);
	} catch (AuthenticationException e) {
		// 3、身份验证失败
		e.printStackTrace();
	}
	Assert.assertEquals(true, subject.isAuthenticated()); // 断言用户已经登录
	System.out.println(subject.isPermitted("user:create"));
	System.out.println(subject.isPermitted("user:update"));
	System.out.println(subject.isPermitted("user:delete"));
	// 4、退出:任何现有的session会清空
	subject.logout();
}
```
输出:
```
true
true
true
```
修改上述用户,以Kiritor/LCore测试,输出为:
```
true
true
false
```
同样shiro提供`checkPermission/checkPermissions`的方式,不同的是当判断为假的时候,会抛出会抛出`UnauthorizedException`异常.  
到此为止基于资源的访问控制就完成了,这种方式的一般规则是”资源标识符:操作”,以资源为单位,一个很大的好处是当权限规则发生变化的时候,基本都是资源级别的修改,不会对其他代码产生影响,粒度较小.需要维护”用户-角色,角色-权限(资源:操作)”之间的关系.就实际情况来说应用系统提供额外模块维护这一关系是非常必要的,可以灵活的定义权限规则.
##授权流程
shiro内部的授权流程是如何的呢?如下图:  
[2]   
流程如下:  
>首先调用`Subject.isPermitted/hasRole`接口,委托给`SecurityManager`,接着`SecuityManager`委托给`Authorizer`;   
`Authorizer`是真正的授权者,如果调用`isPermitted()`,会通过`PermissionResolver`把字符串转换为相应的`Permission`实例;   
进行授权之前,shiro会调用相应的`Realm`获取`Subject`相应的角色/权限用于匹配传入的角色/权限;  
`Authorizer`会判断Realm的角色/权限是否和传入的匹配,多个`Realm`则会委托给`ModularRealmAuthorizer`进行循环判断,匹配返回true,否则返回false(或者抛出异常)表示授权失败.   

`ModularRealmAuthorizer`进行`多Realm`匹配流程:
>检查`Realm`是否实现了`Authorizer`;  
如果实现了`Authorizer`,那么则调用`isPermitted/HasRole`接口进行匹配;  
如果有一个`Realm`匹配那么将返回true,否则返回false.    

`Realm`进行授权,应该集成`AuthorizingRealm`,其流程是:  
>如果调用`hasRole*`,则直接获取`AuthorizationInfo.getRoles()`与传入的角色比较即可;
如果调用`isPermitted`,需要先通过`PermissionResolver`将权限字符串转换成相应的`Permisson`实例,默认使用`WildcardPermissionResolver`,即转换为通配符的`WildcardPermission`;  
通过`AuthorizationInfo.getObjectPermissions()`得到`Permission`实例集合;通过`AuthorizationInfo.getStringPermissions()`得到字符串集合并通过`PermissionResolver`解析为
`Permission`实例;然后获取用户的角色,并通过`RolePermissionResolver`解析角色对应的权限集合  
接着调用`Permission.implies()`逐个与传入的权限比较,有匹配则返回true,反之返回false.    

下面看看授权过程中涉及到的一些接口
#####Authorizer
`Authorizer`主要是进行授权,作为shiro API中授权核心的入口点,提供了相应的角色/权限判断接口。`SecurityManager`继承了`Authorizer`,且提供了`ModularRealmAuthorizer`用于`多Realm`时的权限匹配
#####PermissionResolver
`PermimssionResolver`用于解析权限字符串到`Permission`实例
#####RolePermissionResolver
`RolePermissionResolver`用于根据角色解析相应的权限集合.

本文链接： http://kiritor.github.io/2016/03/10/shiro-Authorization/