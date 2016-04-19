# [Swagger](http://www.swagger.io)
Swagger是干嘛的，请看官网或问谷歌。

Swagger的主要工作流程是：
1. 编写swagger文档，兼容json/yaml两个格式，官方提供[在线编辑器](http://swagger.io/swagger-editor/) -> [Swagger Editor](http://editor.swagger.io)
2. 然后通过[SwaggerUI](http://swagger.io/swagger-ui/)请求第一步编写的swagger文档 -> [Swagger UI](http://petstore.swagger.io/)


so，我们要想用Swagger就必须编写swagger文档，这个时候问题就来了，看看官方的例子：
```js
{
    "swagger": "2.0",
    "info": {
        "title": "Uber API",
        "description": "Move your app forward with the Uber API",
        "version": "1.0.0"
    },
    "host": "api.uber.com",
    "schemes": [
        "https"
    ],
    "basePath": "/v1",
    "produces": [
        "application/json"
    ],
    "paths": {
        "/products": {
            "get": {
                "summary": "Product Types",
                "description": "The Products endpoint returns information about the *Uber* products\noffered at a given location. The response includes the display name\nand other details about each product, and lists the products in the\nproper display order.\n",
                "parameters": [
                    {
                        "name": "latitude",
                        "in": "query",
                        "description": "Latitude component of location.",
                        "required": true,
                        "type": "number",
                        "format": "double"
                    },
                    {
                        "name": "longitude",
                        "in": "query",
                        "description": "Longitude component of location.",
                        "required": true,
                        "type": "number",
                        "format": "double"
                    }
                ],
                "tags": [
                    "Products"
                ],
                "responses": {
                    "200": {
                        "description": "An array of products",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/Product"
                            }
                        }
                    },
                    "default": {
                        "description": "Unexpected error",
                        "schema": {
                            "$ref": "#/definitions/Error"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "Product": {
            "type": "object",
            "properties": {
                "product_id": {
                    "type": "string",
                    "description": "Unique identifier representing a specific product for a given latitude & longitude. For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles."
                },
                "description": {
                    "type": "string",
                    "description": "Description of product."
                },
                "display_name": {
                    "type": "string",
                    "description": "Display name of product."
                },
                "capacity": {
                    "type": "string",
                    "description": "Capacity of product. For example, 4 people."
                },
                "image": {
                    "type": "string",
                    "description": "Image URL representing the product."
                }
            }
        },
        "Error": {
            "type": "object",
            "properties": {
                "code": {
                    "type": "integer",
                    "format": "int32"
                },
                "message": {
                    "type": "string"
                },
                "fields": {
                    "type": "string"
                }
            }
        }
    }
}
```
看完你还想写吗？？？？是不是还不如写word文档？（不过真要我选，我真的会选写这个，够逼格~.~）  
我们想想之前写的接口文档是不是经常会碰到***文档和真正的接口不同步***，因为谁都有***改了代码忘改文档***的时候，这是在所难免的。  
所以我们如果真要编辑上面这份swagger文档也还是会有这个坑。如何避免这个坑呢？当然是直接通过代码生成文档啦，比如**javadoc**，当然javadoc导出来的格式远远达不到我们接口文档所需的要求。 

既然swagger是我们我需要的，我们就要解决怎么通过代码生成swagger文档这个问题。  
Swagger提供了Swagger-Annotations来解决这个问题，我们可以在编写Controller的时候加上Swagger注解，就可以通过Swagger-Core提供的API生成swagger文档。

根据Swagger注解生成文档有两种形式：
1. [swagger-springmvc](https://github.com/springfox/springfox) 现在已升级为**springfox**
2. [swagger-maven-plugin](https://github.com/kongchen/swagger-maven-plugin)
第一种会在项目启动的时候创建一个**api-doc**的接口访问路径然后配合SwaggerUI，这种方式需要SpringMVC3.2以上的版本
第二种会在项目打包的时候生成一份swagger文档，然后根据swagger文档配合SwaggerUI做你想做的。

网上大把的第一种教程。我们项目特殊原因，只能选择后者：
####利用Swagger Maven Plugin生成Rest API文档
首先在项目的pom中添加插件：
```xml
<build>
	<plugins>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-javadoc-plugin</artifactId>
			<configuration>
				<charset>UTF-8</charset>
				<docencoding>UTF-8</docencoding>
				<failOnError>false</failOnError>
			</configuration>
		</plugin>

		<plugin>
			<groupId>com.github.kongchen</groupId>
			<artifactId>swagger-maven-plugin</artifactId>
			<configuration>
				<apiSources>
					<apiSource>
						<springmvc>false</springmvc>
						<locations>com.doctor.demo</locations>
						<schemes>http,https</schemes>
						<host>petstore.swagger.wordnik.com</host>
						<basePath>/api</basePath>
						<info>
							<title>Swagger Maven Plugin Sample</title>
							<version>v1</version>
							<description>This is a sample for swagger-maven-plugin</description>
							<termsOfService>
								http://www.github.com/kongchen/swagger-maven-plugin
							</termsOfService>
							<contact>
								<email>kongchen@gmail.com</email>
								<name>Kong Chen</name>
								<url>http://kongch.com</url>
							</contact>
							<license>
								<url>http://www.apache.org/licenses/LICENSE-2.0.html</url>
								<name>Apache 2.0</name>
							</license>
						</info>
						Support classpath or file absolute path here. 
						1) classpath e.g: "classpath:/markdown.hbs", "classpath:/templates/hello.html" 
						2) file e.g: "${basedir}/src/main/resources/markdown.hbs", "${basedir}/src/main/resources/template/hello.html"
						<templatePath>${basedir}/templates/strapdown.html.hbs</templatePath>
						<outputPath>${basedir}/generated/document.html</outputPath>
						<swaggerDirectory>generated/swagger-ui</swaggerDirectory>
					</apiSource>
				</apiSources>
			</configuration>
			<executions>
				<execution>
					<phase>compile</phase>
					<goals>
						<goal>generate</goal>
					</goals>
				</execution>
			</executions>
		</plugin>
		
	</plugins>
</build>
```
里面用到的模板是官方demo（[swagger-maven-example](https://github.com/swagger-maven-plugin/swagger-maven-example)）中的模板，模板是啥意思不知道就去看插件的官方介绍。

添加好插件后直接在项目下执行`mvn clean compile`就会得到**generated/swagger-ui/swagger.json**


