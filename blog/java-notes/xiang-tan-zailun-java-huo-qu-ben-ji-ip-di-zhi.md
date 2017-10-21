#详谈再论JAVA获取本机IP地址
首先，你如果搜索“JAVA获取本机IP地址”，基本上搜到的资料全是无用的。
比如这篇：http://www.cnblogs.com/zrui-xyu/p/5039551.html
实际上的代码在复杂环境下是不准的


网上一个比较普遍的说法是InetAddress.getLocalHost().getHostAddress()
似乎很简单，但忽略了一个问题，即IP地址在现在的网络环境更加复杂了，比如有Lan，WIFI，蓝牙热点，虚拟机网卡...
即存在很多的网络接口（network interfaces），每个网络接口就包含一个IP地址，并不是所有的IP地址能被外部或局域网访问，比如说虚拟机网卡地址等等。
也就是说InetAddress.getLocalHost().getHostAddress()的IP不一定是正确的IP。

写代码前，先明确一些规则：

* `127.xxx.xxx.xxx` 属于"`loopback`" 地址，即只能你自己的本机可见，就是本机地址，比较常见的有127.0.0.1；
* `192.168.xxx.xxx` 属于`private` 私有地址(site local address)，属于本地组织内部访问，只能在本地局域网可见。同样`10.xxx.xxx.xxx`、从`172.16.xxx.xxx` 到 `172.31.xxx.xxx`都是私有地址，也是属于组织内部访问；
* `169.254.xxx.xxx` 属于连接本地地址（link local IP），在单独网段可用
* 从`224.xxx.xxx.xxx` 到 `239.xxx.xxx.xxx` 属于组播地址
* 比较特殊的`255.255.255.255` 属于广播地址
* 除此之外的地址就是点对点的可用的公开IPv4地址
 

获取本机IP地址的正确姿势：
```java
package ipTest;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Enumeration;

public class Test {

    public Test() {
        // TODO Auto-generated constructor stub
    }

    public static void main(String[] args) {
        // TODO Auto-generated method stub
        InetAddress ip;
        try {
            // 这种IP容易拿错
            // System.out.println("Current IP address : " +
            // InetAddress.getLocalHost().getHostAddress());
            // 不一定准确的IP拿法
            // 出自比如这篇：http://www.cnblogs.com/zrui-xyu/p/5039551.html
            System.out.println("get LocalHost Address : " + getLocalHostAddress().getHostAddress());

            // 正确的IP拿法
            System.out.println("get LocalHost LAN Address : " + getLocalHostLANAddress().getHostAddress());


        } catch (UnknownHostException e) {

            e.printStackTrace();

        }
    }

    // 正确的IP拿法，即优先拿site-local地址
    private static InetAddress getLocalHostLANAddress() throws UnknownHostException {
        try {
            InetAddress candidateAddress = null;
            // 遍历所有的网络接口
            for (Enumeration ifaces = NetworkInterface.getNetworkInterfaces(); ifaces.hasMoreElements();) {
                NetworkInterface iface = (NetworkInterface) ifaces.nextElement();
                // 在所有的接口下再遍历IP
                for (Enumeration inetAddrs = iface.getInetAddresses(); inetAddrs.hasMoreElements();) {
                    InetAddress inetAddr = (InetAddress) inetAddrs.nextElement();
                    if (!inetAddr.isLoopbackAddress()) {// 排除loopback类型地址
                        if (inetAddr.isSiteLocalAddress()) {
                            // 如果是site-local地址，就是它了
                            return inetAddr;
                        } else if (candidateAddress == null) {
                            // site-local类型的地址未被发现，先记录候选地址
                            candidateAddress = inetAddr;
                        }
                    }
                }
            }
            if (candidateAddress != null) {
                return candidateAddress;
            }
            // 如果没有发现 non-loopback地址.只能用最次选的方案
            InetAddress jdkSuppliedAddress = InetAddress.getLocalHost();
            if (jdkSuppliedAddress == null) {
                throw new UnknownHostException("The JDK InetAddress.getLocalHost() method unexpectedly returned null.");
            }
            return jdkSuppliedAddress;
        } catch (Exception e) {
            UnknownHostException unknownHostException = new UnknownHostException(
                    "Failed to determine LAN address: " + e);
            unknownHostException.initCause(e);
            throw unknownHostException;
        }
    }

    //出自这篇：http://www.cnblogs.com/zrui-xyu/p/5039551.html
    //实际上的代码是不准的
    private static InetAddress getLocalHostAddress() throws UnknownHostException {
        Enumeration allNetInterfaces;
        try {
            allNetInterfaces = NetworkInterface.getNetworkInterfaces();
            InetAddress ip = null;
            while (allNetInterfaces.hasMoreElements()) {
                NetworkInterface netInterface = (NetworkInterface) allNetInterfaces.nextElement();

                Enumeration addresses = netInterface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    ip = (InetAddress) addresses.nextElement();
                    if (!ip.isSiteLocalAddress() && !ip.isLoopbackAddress() && ip.getHostAddress().indexOf(":") == -1) {
                        if (ip != null && ip instanceof Inet4Address) {
                            return ip;
                        }
                    }
                }
            }
        } catch (SocketException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        InetAddress jdkSuppliedAddress = InetAddress.getLocalHost();
        if (jdkSuppliedAddress == null) {
            throw new UnknownHostException("The JDK InetAddress.getLocalHost() method unexpectedly returned null.");
        }
        return jdkSuppliedAddress;
    }

}
```
ref:http://www.cnblogs.com/starcrm/p/7071227.html