### Spring MVC 集成 Swagger

Swagger 是一个API文档生成工具，它支持各种语言，甚至支持在线运行实例，本示例基于 HelloWorld-MVC 修改得到。

#### 引入特定的依赖 JAR 包
 pom.xml 中添加如下依赖:
 ```xml
 <dependency>
            <groupId>com.mangofactory</groupId>
            <artifactId>swagger-springmvc</artifactId>
            <version>1.0.2</version>
        </dependency>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
            <version>15.0</version>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-annotations</artifactId>
            <version>2.4.4</version>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.4.4</version>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-core</artifactId>
            <version>2.4.4</version>
        </dependency>
 ```
 最主要的是 swagger-springmvc 依赖，添加了它之后，我们可以使用 Swagger 特定的注解。Swagger 会查找自己的以及 Spring 特定的注解，这样项目部署后默认可以直接使用 <http://host:port/projectName/api-docs>获取所有WEB层的API接口。返回的是标志JSON格式，所以还要添加 Jckson 依赖。
 
 #### 添加Swagger配置
 这里使用 JavaConfig 的方法配置Swagger, 配置类为 SwaggerConfig
 ```java
 package yay.apidoc.config;

import com.mangofactory.swagger.configuration.SpringSwaggerConfig;
import com.mangofactory.swagger.models.dto.ApiInfo;
import com.mangofactory.swagger.plugin.EnableSwagger;
import com.mangofactory.swagger.plugin.SwaggerSpringMvcPlugin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

/**
 * @author albert
 * @version 1.0
 * @since JDK 1.7
 */
@Configuration
@EnableSwagger
@EnableWebMvc
public class SwaggerConfig {

    private SpringSwaggerConfig springSwaggerConfig;

    /**
     * Required to autowire SpringSwaggerConfig
     */
    @Autowired
    public void setSpringSwaggerConfig(SpringSwaggerConfig springSwaggerConfig)
    {
        this.springSwaggerConfig = springSwaggerConfig;
    }

    /**
     * Every SwaggerSpringMvcPlugin bean is picked up by the swagger-mvc
     * framework - allowing for multiple swagger groups i.e. same code base
     * multiple swagger resource listings.
     */
    @Bean
    public SwaggerSpringMvcPlugin customImplementation()
    {
        return new SwaggerSpringMvcPlugin(this.springSwaggerConfig)
                .apiInfo(apiInfo())
                .includePatterns(".*");
    }

    private ApiInfo apiInfo()
    {
        ApiInfo apiInfo = new ApiInfo(
                "Spring MVC Demo",
                "Spring MVC 简单示例，依赖于 MySQL 数据库，只有简单的登陆功能。",
                "开发者: Albert Chen",
                "albert.chen.dao@gmail.com",
                "MIT License",
                "/LICENSE");
        return apiInfo;
    }
}
```

**新增一个Controller**
```java
package yay.apidoc.controller;

import io.swagger.annotations.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import yay.apidoc.model.UamGroup;

import java.util.LinkedList;
import java.util.List;

/**
 * Created by yuananyun on 2015/11/23.
 */
@Controller
@RequestMapping(value = "/group", produces = {"application/json;charset=UTF-8"})
@Api(value = "/group", description = "群组的相关操作")
public class GroupController {
    @RequestMapping(value = "addGroup", method = RequestMethod.PUT)
    @ApiOperation(notes = "addGroup", httpMethod = "POST", value = "添加一个新的群组")
    @ApiResponses(value = {@ApiResponse(code = 405, message = "invalid input")})
    public UamGroup addGroup(@ApiParam(required = true, value = "group data") @RequestBody UamGroup group) {
        return group;
    }

    @RequestMapping(value = "getAccessibleGroups", method = RequestMethod.GET)
    @ApiOperation(notes = "getAccessibleGroups", httpMethod = "GET", value = "获取我可以访问的群组的列表")
    public List<UamGroup> getAccessibleGroups() {
        UamGroup group1 = new UamGroup();
        group1.setGroupId("1");
        group1.setName("testGroup1");

        UamGroup group2 = new UamGroup();
        group2.setGroupId("2");
        group2.setName("testGroup2");

        List<UamGroup> groupList = new LinkedList<UamGroup>();
        groupList.add(group1);
        groupList.add(group2);

        return groupList;
    }
}
```
其中UamGroup的定义如下：
```java
package yay.apidoc.model;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

/**
 * 群组
 */
@ApiModel
public class UamGroup {
    /**
     * 编号
     */
    @ApiModelProperty(value = "群组的Id", required = true)
    private String groupId;
    /**
     * 名称
     */
    @ApiModelProperty(value = "群组的名称", required = true)
    private String name;
    /**
     * 群组图标
     */
    @ApiModelProperty(value = "群组的头像", required = false)
    private String icon;

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }
}
```

#### 将配置注入到容器
在 DispatcherServlet 的配置 ~servlet.xml 里注入 Swagger 配置对象:
```
    <context:component-scan base-package="yay.apidoc.controller"/>
```
这样其实就可以部署启动，然后直接访问<http://host:port/projectName/api-docs>获取所有通过 `@Controller`、`@RequestMapping`等注解配置的WEB接口。

#### 集成 Swagger-ui界面
Swagger 提供了一个静态项目 Swagger-ui，可以帮忙将获得的JSON格式的API优美的展示出来并且帮助测试这些接口。
集成 Swagger-ui 很简单，从<https://github.com/swagger-api/swagger-ui> 获取其所有的 dist 目录下东西放到需要集成的项目里，比如这里放入 src/main/webapp/WEB-INF/swagger-ui/ 目录下

然后在 user-servlet.xml 里添加这些静态文件映射:
```
    <mvc:resources mapping="/swagger/**" location="/WEB-INF/swagger-ui/"/>
```
重新部署启动后，访问<http://host:port/projectName/swagger/index.html> 即可看到 Swagger-ui的界面。默认是从连接<http://petstore.swagger.io/v2/swagger.json>获取 API 的 JSON，不过可以在 Swagger-ui 的静态文件的 index.html 中配置为 <http://host:port/projectName/api-docs>。


#### 使用Swagger特定注解

Swagger 包含了一些特定的注解，可以更好的显示API，比如:
* `@API`表示一个开放的API，可以通过description简要描述该API的功能，一般和 Spring 的 `@Controller`一起。
* 在一个`@API`下，可有多个`@ApiOperation`，表示针对该API的CRUD操作。在ApiOperation Annotation中可以通过value，notes描述该操作的作用，response描述正常情况下该请求的返回对象类型。
* 在一个ApiOperation下，可以通过ApiResponses描述该API操作可能出现的异常情况。
* `@ApiParam`用于描述该API操作接受的参数类型
* `@ApiModel`用来描述封装的参数对象与返回的参数对象
* `@ApiModelProperty`描述ApiModel的属性


 
 