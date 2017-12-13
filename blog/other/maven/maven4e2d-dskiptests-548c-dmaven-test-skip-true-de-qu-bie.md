#Maven中-DskipTests和-Dmaven.test.skip=true的区别  
在使用`mvn package`进行编译、打包时，`Maven`会执行`src/test/java`中的`JUnit`测试用例，有时为了跳过测试，会使用参数`-DskipTests`和`-Dmaven.test.skip=true`，这两个参数的主要区别是：

`-DskipTests`，不执行测试用例，但编译测试用例类生成相应的`class`文件至`target/test-classes`下。  

`-Dmaven.test.skip=true`，不执行测试用例，也不编译测试用例类。