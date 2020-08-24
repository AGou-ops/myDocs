# Java 日志收集 

## Java 多行日志收集

首先，配置好`jdk`和`tomcat`，在此就不赘述。

确保，测试站点可以正常访问：

```bash
[root@es-01 tomcat]\# curl localhost:8080/testpage/index.html
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
<h1>test tomcat page</h1>
```

修改`tomcat`服务的配置文件，收集log日志为`json`格式，编辑配置文件`conf/server.xml`：

```xml
<!-- 大概在164行左右 -->
<!-- 修改日志文件后缀为.log -->
<!-- 修改日志记录内容 -->
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" 
               prefix="tomcat_access_log" suffix=".log" 	
               pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}"/> 
```

> `&quot;`是英文引号`"`的意思。

保存退出， 随后重启tomcat服务器：

```bash
bin/shutdown.sh
bin/startup.sh
```

**<u>准备工作完成之后，开始收集`tomcat`的日志</u>**

为`tomcat`创建日志收集配置文件：

```bash
mkdir config.d;cd config.d
vim config.d/tomcat-log.conf
# -----
input {
  file {
   path => "/usr/local/logstash-7.7.1/logs/logstash-plain.log"   收集jav 的日志文件目录
   start_position => "beginning"
   stat_interval => 3
   type => "java-log"
  }

  file {
   path => "/usr/local/tomcat/logs/tomcat_access_log.*.log"  # 收集tomca 日志的文件目录
   start_position => "beginning"
   stat_interval => 3
   type => "tomcat-access-log"
   codec => "json"  # 输出tomcat 的json日志格式
  }
}

output {
  if [type] == "java-log" {
   elasticsearch {
   hosts => ["172.16.1.128:9200"]
   index => "javalog-7-102-%{+YYYY.MM.dd}"
   }
  }

  if [type] == "tomcat-access-log" {
   elasticsearch {
   hosts => ["172.16.1.128:9200"]
   index => "tomcat-access-log-7-102-%{+YYYY.MM.dd}"
   }
  }
}

# ----
```







## 参考资料

https://www.cnblogs.com/struggle-1216/p/12488650.html