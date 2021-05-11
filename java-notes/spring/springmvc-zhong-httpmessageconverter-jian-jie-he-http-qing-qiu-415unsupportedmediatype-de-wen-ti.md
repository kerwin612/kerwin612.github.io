# SpringMVC 中HttpMessageConverter简介和Http请求415 Unsupported Media Type的问题

## 一、概述：

本文介绍且记录如何解决在SpringMVC 中遇到 `415 Unsupported Media Type` 的问题，并且顺便介绍Spring MVC的HTTP请求信息转换器**HttpMessageConverter**。

## 二、问题描述：

在SprinvMVC的Web程序中，我在页面发送Ajax 的POST请求，然后在服务器端利用@Requestbody接收请求body中的参数，当时运行过程中，我向服务器发送Ajax请求，浏览器一直反馈415 Unsupported Media Type或者400的状态码，以为是Ajax写的有问题。便查找了半天资料，才发现spring-mvc.config文件的配置中少了东西，当然也有可能是你真的在Ajax中缺少了对Content-Type参数的设置。分析后应该是我springMVC-config.xml文件配置有问题。

**（注）**：**400**：（错误请求） 服务器不理解请求的语法。 **415**：（不支持的媒体类型） 请求的格式不受请求页面的支持。

## 三、解决方法：

在springMVC-config.xml文件中，增加了一个**StringHttpMessageConverter**请求信息转换器，配置片段如下：

```markup
<!--- StringHttpMessageConverter bean -->
<bean id = "stringHttpMessageConverter" class = "org.springframework.http.converter.StringHttpMessageConverter"/>

<!-- 启动Spring MVC的注解功能，完成请求和注解POJO的映射 -->
<bean class ="org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter" >
       <property name= "messageConverters" >
             <list>
                 <ref bean= "mappingJacksonHttpMessageConverter" />
                 <!-- 新增的StringMessageConverter bean-->
                 <ref bean= "stringHttpMessageConverter" />
                 <ref bean= "jsonHttpMessageConverter" />           
                 <ref bean= "formHttpMessageConverter" />
             </list>
        </property>
</bean>
```

## 四、HttpMessageConverter请求信息转换器简介：

HttpMessageConverter接口指定了一个可以把Http request信息和Http response信息进行格式转换的转换器。通常实现HttpMessageConverter接口的转换器有以下几种： 1. **ByteArrayHttpMessageConverter**: 负责读取二进制格式的数据和写出二进制格式的数据； 2. **StringHttpMessageConverter**: 负责读取字符串格式的数据和写出二进制格式的数据； 3. **ResourceHttpMessageConverter**: 负责读取资源文件和写出资源文件数据； 4. **FormHttpMessageConverter**: 负责读取form提交的数据（能读取的数据格式为 application/x-www-form-5. urlencoded，不能读取multipart/form-data格式数据）；负责写入application/x-www-from-urlencoded和multipart/form-data格式的数据； 5. **MappingJacksonHttpMessageConverter**: 负责读取和写入json格式的数据； 6. **SourceHttpMessageConverter**: 负责读取和写入 xml 中javax.xml.transform.Source定义的数据； 7. **Jaxb2RootElementHttpMessageConverter**: 负责读取和写入xml 标签格式的数据； 8. **AtomFeedHttpMessageConverter**: 负责读取和写入Atom格式的数据； 9. **RssChannelHttpMessageConverter**: 负责读取和写入RSS格式的数据；

**（注）**更多关于HttpMessageConverter的信息请看：[http://docs.spring.io/spring/docs/3.0.x/api/org/springframework/http/converter/HttpMessageConverter.html](http://docs.spring.io/spring/docs/3.0.x/api/org/springframework/http/converter/HttpMessageConverter.html)

## 五、HttpMessageConverter请求信息转换器执行流程：

当用户发送请求后，**@Requestbody** 注解会读取请求body中的数据，默认的请求转换器 **HttpMessageConverter** 通过获取请求头 _Header_ 中的 **Content-Type** 来确认请求头的数据格式，从而来为请求数据适配合适的转换器。例如 _**Content-Type:applicatin/json**_ ，那么转换器会适配 _**MappingJacksonHttpMessageConverter**_ 。响应的时候同理， **@Responsebody** 注解会启用 **HttpMessageConverter** ，通过检测 _Header_ 中 **Accept** 属性来适配的响应的转换器。

**总结：**  
当在使用SpringMVC做服务器数据接收时，尤其是在做Ajax请求的时候，尤其要注意 Content-Type 属性，和 Accept 属性的设置，在springmvc-config.xml中配置好相应的转换器。当我们在用SpringMVC做 Ajax 请求的时候，有的做法用response.getWriter\(\).print\(\)的方法，还有更好的方法就是添加@Responsebody注解，直接返回Map类型的数据，转换器自动转换为JSON数据类型。

