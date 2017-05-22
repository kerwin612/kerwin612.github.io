#Shiro-Authentication(身份验证)

##Authentication  
Authentication是指身份验证的过程:即在应用中能证明他就是他本人.一般需要提供身份标识信息例如:ID,用户名/密码等.
在Shiro中,用户需要提供Principals和Credentials给Shiro,从而来验证用户的身份.
Principals: 身份,即是Subject的标识属性,可以是任何东西,诸如用户名、邮箱等,唯一即可.一个主题可以有多个Principal,但是只有一个Primary principal一般是用户名/密码.
Credentials: 证明/凭据,只有主体才知道的安全值,如密码/数字证书.
principal/credential配对最常见的就是用户名/密码.

##Demo
在实际研究Shiro身份认证流程之前,先搭建一个架子,进行简单的验证.
#####Maven构建
添加junit、common-logging以及shiro-core等依赖.
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.lcore.shiro_01</groupId>
	<artifactId>shiro_01</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<dependencies>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>4.9</version>
		</dependency>
		<dependency>
			<groupId>commons-logging</groupId>
			<artifactId>commons-logging</artifactId>
			<version>1.1.3</version>
		</dependency>
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-core</artifactId>
			<version>1.2.2</version>
		</dependency>
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-nop</artifactId>
			<version>1.7.5</version>
		</dependency>
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
			<version>5.1.25</version>
		</dependency>
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>druid</artifactId>
			<version>0.2.23</version>
		</dependency>
	</dependencies>
</project>
```
#####shiro配置文件ini方式(shiro.ini)
简洁起见,这里仅仅配置一个用户名/密码(principal/credential),其他使用shiro默认配置.
```ini
[users]
#用户名及其对应的密码
L.Tao=LCore
```
之后编写一个简单的测试用例,shiro最简单的身份认证demo就完成了,代码如下:
```java
@Test
public void testHello() {
	// 1、通过ini文件获取securityManager工厂
	Factory<SecurityManager> factory = new IniSecurityManagerFactory(
			"classpath:shiro.ini");
	// 2、得到securityManager实例,绑定SecurityUtils
	SecurityManager manager = factory.getInstance();
	SecurityUtils.setSecurityManager(manager);
	// 3、得到Subject及创建用户名/密码身份验证Token（即用户身份/凭证）
	Subject subject = SecurityUtils.getSubject();
	UsernamePasswordToken token = new UsernamePasswordToken("L.Tao", "LCore");
	try {
		// 4、登录，即身份验证,委托给securityManager
		subject.login(token);
	} catch (AuthenticationException e) {
		// 5、身份验证失败
		e.printStackTrace();
	}
	Assert.assertEquals(true, subject.isAuthenticated()); // 断言用户已经登录
	// 6、退出:任何现有的session会清空
	subject.logout();
}
```
关于上述demo的执行过程,注释已经说得很明白了,需要提及的是,在调用subject.login()身份验证失败时,请捕获AuthenticationException或其子类,常见的如DisabledAccountException(禁用的账户)、LockedAccountException(锁定的账户)、UnknowAccountException(错误的账户)等,具体情况如下图:
[1]

##身份认证流程
demo中可以简单的了解Shiro的认证过程,接下来从shiro内部体系结构了解其认证流程:
[2]
流程如下:
>1、首先调用Subject.login()方法进行登录,内部会委托给SecurityManager,调用之前需要通过SecurityUtils,setSecurityManager()设置.
2、SecurityManager委托给Authenticator进行身份验证,Authenticator才是真正的身份验证者,也可以扩展实现自己的Authenticator.
3、Authenticator可能会委托给相应的AuthenticationStrategy进行多Realm身份验证,默认为ModularRealmAuthenticator会调用AuthenticationStrategy进行多Realm身份验证.
4、Authenticator会把相应的token传入Realm,从Realm获取身份验证信息,可以配置多个Realm,将按照相应的顺序和策略进行访问,最后完成身份认证.

阅读源码内部的的流程还是比较复杂的,大致的时序图如下:
[3]
上述只是一个大致的流程,实际情况复杂的多.

##Realm
Realm:安全数据源,用于获取安全数据(用户、角色、权限规则),shiro通过SecurityManager验证用户,必须通过Realm获取相应的用户进行比较以确定用户是否合法.同样也是通过Realm得到用户相应的角色/权限控制用户的访问权限.shiro默认提供的Realm如下图:
[4]
上述图中可以知道的是,如果我们实现自定义的Realm一般继承AuthorizingRealm(授权)即可,因为其继承了AuthenticationgRealm和CachingRealm实现了身份验证和缓存.主要实现:
>IniRealm: [users]部分指定其用户名/密码及其角色,[roles]部分指定其角色,权限信息.demo中就是使用的此方式.
JdbcRealm: 通过SQL查询相应的信息,其相应的sql可以查阅源码查看,也可以通过api进行自定义SQL.

仔细思考一下可以知道,在实际中我们一般不会使用shiro提供的Realm,前面也说了shiro不维护用户/权限,仅仅通过Realm进行注入.Shiro提供的Realm总归不够灵活,因此正如上述所说,一般我们通过继承AuthorizingRealm实现自定义的Realm(结合自身的dao层,获取安全数据).
接下来了解下Realm如何使用.
#####单Realm配置
1、 自定义Realm实现:
```java
package com.shiro_01.realm;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.realm.Realm;
public class MyRealm1 implements Realm{
	public String getName() {
		return "myreal1";
	}
	public boolean supports(AuthenticationToken token) {
		return token instanceof UsernamePasswordToken;
	}
	public AuthenticationInfo getAuthenticationInfo(AuthenticationToken token)
			throws AuthenticationException {
        String username = token.getPrincipal().toString();
        String password = new String((char[])token.getCredentials());
        System.out.println("realm1");
		//自己实现验证逻辑
        if(!username.equals("L.Tao")){
        	throw new UnknownAccountException("没有该用户");
        }
        if(!password.equals("LCore")){
        	throw new IncorrectCredentialsException("密码错误");
        }
		return new SimpleAuthenticationInfo(username+"1", password, getName());
	}
 
}
```
2、ini配置文件指定自定义的Realm
```ini
#声明一个realm
myRealm1=com.shiro_01.realm.MyRealm1
#指定SecurityManager的realms实现
securityManager.realms=$myRealm1
```
通过$name来引入之前定义好的realm
3、测试代码:
```java
public void testCustomRealm() {
	// 1、获取SecurityManager工厂，此处使用Ini配置文件初始化SecurityManager
	Factory<org.apache.shiro.mgt.SecurityManager> factory = new IniSecurityManagerFactory(
			"classpath:shiro-realm.ini");
	// 2、得到SecurityManager实例 并绑定给SecurityUtils
	org.apache.shiro.mgt.SecurityManager securityManager = factory
			.getInstance();
	SecurityUtils.setSecurityManager(securityManager);
	// 3、得到Subject及创建用户名/密码身份验证Token（即用户身份/凭证）
	Subject subject = SecurityUtils.getSubject();
	UsernamePasswordToken token = new UsernamePasswordToken("L.Tao",
			"LCore");
	try {
		// 4、登录，即身份验证
		subject.login(token);
	} catch (AuthenticationException e) {
		// 5、身份验证失败
		e.printStackTrace();
	}
	Assert.assertEquals(true, subject.isAuthenticated()); // 断言用户已经登录
	// 6、退出
	subject.logout();
}
```
#####JDBC Realm
Shiro提供的JDBC Realm使用也是比较简单且较为灵活的,使用方法如下:
1、maven添加数据库驱动及druid连接池,参考上述pom.xml
2、建立测试数据库及数据表数据,建表:users、user_roles,roles_permissions,并且添加一个测试用户:
```sql
-- ----------------------------
-- Table structure for roles_permissions
-- ----------------------------
DROP TABLE IF EXISTS `roles_permissions`;
CREATE TABLE `roles_permissions` (
  `id` bigint(20) NOT NULL auto_increment,
  `role_name` varchar(100) default NULL,
  `permission` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_roles_permissions` (`role_name`,`permission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of roles_permissions
-- ----------------------------
-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL auto_increment,
  `username_` varchar(100) default NULL,
  `password_` varchar(100) default NULL,
  `password_salt` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_users_username` (`username_`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('1', 'L.Tao', 'LCore', '');
-- ----------------------------
-- Table structure for user_roles
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `id` bigint(20) NOT NULL auto_increment,
  `username` varchar(100) default NULL,
  `role_name` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_user_roles` (`username`,`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
之前,也说过Shiro并不维护用户/权限,实际系统的表结构并不像上述的设计,只是shiro的jdbcRealm默认是上述的.不过没关系,我们可以通过相关的接口重新指定验证的SQL,后面会提及.
3、ini配置
```ini
jdbcRealm=org.apache.shiro.realm.jdbc.JdbcRealm
dataSource=com.alibaba.druid.pool.DruidDataSource
dataSource.driverClassName=com.mysql.jdbc.Driver
dataSource.url=jdbc:mysql://localhost:3306/shiro
dataSource.username=root
dataSource.password=root
jdbcRealm.dataSource=$dataSource
#权限认证sql,这里我修改了底层user表的两个字段,因此这里要自己重新指定sql,不然报错,默认的为:
#select password from users where username = ?
#同理,角色信息,权限信息也可以自己指定
jdbcRealm.authenticationQuery=select password_ from users where username_ = ?
securityManager.realms=$jdbcRealm
```
>变量名=全类名 会自动创建实例
变量名.属性=值 自动调用相应的setter方法进行赋值
$变量名 引用之前的一个对象实例
4、测试代码
测试代码和上面并无太大区别,主要是初始化SecurityManager使用的配置文件不同
#####多Realm配置
在进行多Realm配置之前,有必要了解下,shiro是如何进行验证的,在之前的shiro验证流程图中已经了解到Subject.login()会交由DefaultSecurityManager的Authenticator进行验证authenticate().Authenticator的职责是验证用户账号,是ShiroAPI中身份验证的核心入口点.
跟踪源码,Authenticator还有一个ModularRealmAuthenticator实现,实际上是它委托给多个(也可以是单个)Realm进行验证,多个Realm的验证规则通过AuthenticationStrategy接口指定,阅读源码可知道,ModularRealmAuthenticator构造器默认指定的是AtleastOneSuccessfulStrategy(只要有一个Realm验证成功即可),且返回所有验证成功的认证信息.
具体来说Shiro默认提供的验证规则有如下几个:
>FirstSuccessfulStrategy:只要有一个Realm验证成功即可,返回第一个Realm验证成功的信息,其余忽略.
AtLeastOneSuccessfulStrategy:只要有一个验证成功即可,返回所有验证成功的验证信息.
AllSuccessfulStrategy:所有Realm验证成功即可,返回所有验证成功的验证信息.
多Realm的配置也比较容易,ini配置如下:
```ini
#authenticator
authenticator=org.apache.shiro.authc.pam.ModularRealmAuthenticator
securityManager.authenticator=$authenticator
allSuccessfulStrategy=org.apache.shiro.authc.pam.AllSuccessfulStrategy
securityManager.authenticator.authenticationStrategy=$allSuccessfulStrategy
myRealm1=com.shiro_01.realm.MyRealm1
myRealm2=com.shiro_01.realm.MyRealm2
myRealm3=com.shiro_01.realm.MyRealm3
securityManager.realms=$myRealm1,$myRealm3
```
SecurityManager会按照realms指定的顺序进行验证,如果不指定,则会按照声明的顺序进行验证.如果显示指定顺序,声明了但是没有指定的会被忽略.上述3个自定义的Realm和之前并无太大区别,可以调整其验证规则,用于测试Shiro提供的3中验证策略.之后根据如下代码获取验证信息:
```java
Subject subject = SecurityUtils.getSubject();
PrincipalCollection principals = subject.getPrincipals();
```
Shiro同样可以实现自定义的验证策略,比如我们实现一个OnlyOneAuthenticatorStrategy(只有一个验证通过才验证通过)
1、 实现OnlyOneAuthenticatorStrategy:
```java
package com.shiro_01.strategy;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authc.pam.AbstractAuthenticationStrategy;
import org.apache.shiro.realm.Realm;
import org.apache.shiro.util.CollectionUtils;
import java.util.Collection;
public class OnlyOneAuthenticatorStrategy extends AbstractAuthenticationStrategy {
	//所有Realm验证之前
    @Override
    public AuthenticationInfo beforeAllAttempts(Collection<? extends Realm> realms, AuthenticationToken token)
	throws AuthenticationException {
        return new SimpleAuthenticationInfo();//返回一个权限的认证信息
    }
    //每个Realm验证之前
    @Override
    public AuthenticationInfo beforeAttempt(Realm realm, AuthenticationToken token, AuthenticationInfo aggregate)
	throws AuthenticationException {
        return aggregate;//返回之前合并的
    }
    //每个Realm验证之后
    @Override
    public AuthenticationInfo afterAttempt(Realm realm, AuthenticationToken token, 
	AuthenticationInfo singleRealmInfo, AuthenticationInfo aggregateInfo, Throwable t) 
	throws AuthenticationException {
        AuthenticationInfo info;
        if (singleRealmInfo == null) {
            info = aggregateInfo;
        } else {
            if (aggregateInfo == null) {
                info = singleRealmInfo;
            } else {
                info = merge(singleRealmInfo, aggregateInfo);
                if(info.getPrincipals().getRealmNames().size() != 1) {
                    throw new AuthenticationException("只能有一个验证通过");
                }
            }
        }
        return info;
    }
    //所有realm验证之后
    @Override
    public AuthenticationInfo afterAllAttempts(AuthenticationToken token, AuthenticationInfo aggregate)
	throws AuthenticationException {
        return aggregate;
    }
}
```
根据策略,我们需要在每次验证之后,合并验证信息,只要验证信息不等于1(都没有通过/通过多于1次)即是验证失败.之后在ini配置文件中,手动指定验证策略即可
具体就不在测试了,到此,Shiro身份验证OVER了!

本文链接： http://kiritor.github.io/2015/09/28/shiro-Authentication/