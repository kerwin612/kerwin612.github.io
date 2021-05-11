# HighChart利用servlet导出中文PNG图片乱码问题解决

最近用到HighChart作图，在图片导出时，出现了图片中中文乱码的问题，在网络上找了很多资料，但都没有解决，最后才发现了最容易被忽略的问题。具体见下。

由于之前有同事使用过HighChart，所以毫不犹豫了之前同事使用的方法：通过自己书写servlet，利用batik工具完成不同格式图片的导出，具体方法见下：

```java
    @RequestMapping(value = "/save_image", method = RequestMethod.POST)
    public void saveImage(HttpServletRequest request,
            HttpServletResponse response, String type, String svg,
            String filename) throws IOException {
        request.setCharacterEncoding("utf-8");
        filename = filename == null ? "chart" : filename;
        ServletOutputStream out = response.getOutputStream();

        if (null != type && null != svg) {
            svg = svg.replaceAll(":rect", "rect");
            String ext = "";
            Transcoder t = null;
            if (type.equals("image/png")) {
                ext = "png";
                t = new PNGTranscoder();
            } else if (type.equals("image/jpeg")) {
                ext = "jpg";
                t = new JPEGTranscoder();
            } else if (type.equals("application/pdf")) {
                ext = "pdf";
                t = (Transcoder) new PDFTranscoder();
            } else if (type.equals("image/svg+xml"))
                ext = "svg";

            response.addHeader("Content-Disposition", "attachment; filename="
                    + filename + "." + ext);
            response.addHeader("Content-Type", type);

            if (null != t) {
                TranscoderInput input = new TranscoderInput(new StringReader(
                        svg));
                TranscoderOutput output = new TranscoderOutput(out);

                try {
                    t.transcode(input, output);
                } catch (TranscoderException e) {
                    out.print("Problem transcoding stream. See the web logs for more details.");
                }
            } else if (ext.equals("svg")) {
                OutputStreamWriter writer = new OutputStreamWriter(out, "UTF-8");
                writer.append(svg);
                writer.close();
            } else
                out.print("Invalid type: " + type);
        } else {
            response.addHeader("Content-Type", "text/html");
            out.println("Usage:\n\tParameter [svg]: The DOM Element to be converted."
                    + "\n\tParameter [type]: The destination MIME type for the elment to be transcoded.");
        }
        out.flush();
        out.close();
    }
```

之后修改exporting.js文件，将其中的导出URL改为上述servlet中指定的URL。方法与网络上的大致相同。

但是问题来了，测试的同事告诉我部署在Linux服务器上的应用在导出图片时，中文都变成了小框框，一般这种乱码问题都会想到是编码问题，于是开始在网络上找解决方法。

首先根据[http://ollevere.iteye.com/blog/1773563](http://ollevere.iteye.com/blog/1773563)中提到的解决方法二，在代码中添加了

```java
request.setCharacterEncoding("utf-8");
```

部署测试之后，发现不管用

于是，继续海搜，看到了[http://jstree.iteye.com/blog/1586623](http://jstree.iteye.com/blog/1586623)，又在代码中加下

```java
response.setCharacterEncoding("utf-8");
```

部署测试后，发现还是不管用

其实，我在工程的servlet配置中，已经对字体做了转码配置。如果没有进行配置，还是要像上面提到的方法控制servlet中的编码。

```markup
    <mvc:annotation-driven>
        <mvc:message-converters register-defaults="true">
            <!-- 将StringHttpMessageConverter的默认编码设为UTF-8 -->
            <bean class="org.springframework.http.converter.StringHttpMessageConverter">
                <constructor-arg value="UTF-8" />
            </bean>
            <!-- 将Jackson2HttpMessageConverter的默认格式化输出设为true -->
            <bean
                class="org.springframework.http.converter.json.MappingJackson2HttpMessageConverter">
                <property name="prettyPrint" value="true" />
                <property name="supportedMediaTypes">
                    <list>
                        <value>text/html;charset=UTF-8</value>
                    </list>
                </property>
            </bean>
        </mvc:message-converters>
    </mvc:annotation-driven>
```

这时我测试发现，部署在本地（Windows7系统）tomcat服务器上的应用并没有这个问题，导出的图片中中文显示得很正常，这时，有点懵了。

于是想到是不是Linux服务器上有什么地方没有配置正确？但在比较本地tomcat和服务器tomcat的配置之后，发现两者大同小异，甚至我把本地的配置拷贝到服务器，部署测试后，问题仍然存在。想到会不会是java版本不同，结果看了，Linux服务器上用的是Java1.7，而本地用的是Java1.6。但是看了下也没有找到问题所在。

这时，自己感觉很无力，也几乎耽误了一天时间了。

于是开始找同事咨询，同事看了之后就提到说是不是Linux服务器上是不是不支持设定的中文字体，突然感觉眼前一亮，可能找到问题所在了，于是前端同事配合修改highchart画图时设置的font-family，添加了linux中默认的字体Monospace，但是问题仍没有解决。

之后找做系统方面的同事咨询：是Linux系统中缺少中文字体包还是jdk中缺少中文字体包才导致这个问题，他给出的答案是应该是jdk中缺少中文字体包，于是，**在jdk中安装了几个常用的中文字体包**，再部署应用测试，问题解决了。虽然之前也想到可能是服务器上配置的问题，但没想到是JDK中缺少中文字体包，还是经验不足啊。

此次的查错过程甚是曲折，不过总算把问题解决了，特意整理出来，供大家参考。有不足之处，请大家见谅。

