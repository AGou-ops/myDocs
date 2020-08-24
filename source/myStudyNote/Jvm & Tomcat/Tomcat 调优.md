# Tomcat 调优 

### 修改 tomcat 启动模式

tomcat的运行模式有3种：

**bio：**默认的模式,性能非常低下,没有经过任何优化处理和支持.

**nio：**nio(new I/O)，是Java SE 1.4及后续版本提供的一种新的I/O操作方式(即java.nio包及其子包)。Java nio是一个基于缓冲区、并能提供非阻塞I/O操作的Java API，因此nio也被看成是non-blocking I/O的缩写。它拥有比传统I/O操作(bio)更好的并发运行性能。

**apr：**安装起来最困难,但是从操作系统级别来解决异步的IO问题,大幅度的提高性能.

**启动NIO模式**

修改`server.xml`里的Connector节点：

```xml
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
-- 在`71`行左右将其改为
    <Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
               connectionTimeout="20000"
               redirectPort="8443" />

```

### 执行器优化（线程池）

在tomcat中每一个用户请求都是一个线程，所以可以使用线程池提高性能。

```xml
  <Service name="Catalina">

    <!--The connectors can use a shared executor, you can define one or more named thread pools-->
-- 在`59`行左右取消注释以下内容
    <!--
    <Executor name="tomcatThreadPool" namePrefix="catalina-exec-"
        maxThreads="150" minSpareThreads="4"/>
    -->

      
```

在`Connector`中指定使用共享线程池：

```xml
-- 在 connector 中指定线程池
	<Connector  executor="tomcatThreadPool" port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
                connectionTimeout="20000"
               redirectPort="8443" />
```

**Executor重要参数说明：**

name：共享线程池的名字。这是Connector为了共享线程池要引用的名字，该名字必须唯一。默认值：None；

namePrefix:在JVM上，每个运行线程都可以有一个name 字符串。这一属性为线程池中每个线程的name字符串设置了一个前缀，Tomcat将把线程号追加到这一前缀的后面。默认值：tomcat-exec-；

maxThreads：该线程池可以容纳的最大线程数。默认值：200；

maxIdleTime：在Tomcat关闭一个空闲线程之前，允许空闲线程持续的时间(以毫秒为单位)。只有当前活跃的线程数大于minSpareThread的值，才会关闭空闲线程。默认值：60000(一分钟)。

minSpareThreads：Tomcat应该始终打开的最小不活跃线程数。默认值：25。

threadPriority：线程的等级。默认是Thread.NORM_PRIORITY

**Connector重要参数说明：**

executor：表示使用该参数值对应的线程池；

minProcessors：服务器启动时创建的处理请求的线程数；

maxProcessors：最大可以创建的处理请求的线程数；

acceptCount：指定当所有可以使用的处理请求的线程数都被使用时，可以放到处理队列中的请求数，超过这个数的请求将不予处理。

**最佳参数实践：**

![](http://p3.pstatp.com/large/pgc-image/b6f4cfebbff84bc99e79f78c3ca288bb)

### 禁用AJP连接器

**AJP（Apache JServer Protocol）**
AJPv13协议是面向包的。WEB服务器和Servlet容器通过TCP连接来交互；为了节省SOCKET创建的昂贵代价，WEB服务器会尝试维护一个永久TCP连接到servlet容器，并且在多个请求和响应周期过程会重用连接。

我们一般是使用Nginx+tomcat的架构，所以用不着AJP协议，所以把AJP连接器禁用。

在`server.xml`文件中，注释以下内容即可：

```xml
 92     <!-- Define an AJP 1.3 Connector on port 8009 -->
 93     <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
 94 
```

