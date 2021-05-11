# JAVA 判断一个字符串是不是一个合法的日期格式

一直找不到合适的正则表达式可以判断一个字符串是否可以转成日期，今天发现可以采用SimpleDateFormat类的parse方法进行判断，如果转换不成功，就会出现异常，

具体代码如下：

```java
public static boolean isValidDate(String str) {
　　// 指定日期格式为四位年/两位月份/两位日期，注意yyyy/MM/dd区分大小写；
    SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd HH:mm");
    try {
　　　　// 设置lenient为false. 否则SimpleDateFormat会比较宽松地验证日期，比如2007/02/29会被接受，并转换成2007/03/01
        format.setLenient(false);
        format.parse(str);
        return true;
    } catch (ParseException e) {
        // 如果throw java.text.ParseException或者NullPointerException，就说明格式不对
        //e.printStackTrace();        
    } 
    return false;
}
```

