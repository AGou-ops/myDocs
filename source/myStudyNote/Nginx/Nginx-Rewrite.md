# Nginx-Rewrite 

## Nginx-rewrite

Rewrite规则可以实现对url的重写，以及重定向

### 应用场景

-  调整用户浏览的URL，看起来规范
- 为了让搜索引擎收录网站内容，让用户体验更好
- 网站更换新域名
- 根据特殊的变量、目录、客户端信息进行跳转

### 配置语法

- Syntax： rewrite regex replacement [flag];
- Default：——
- Context：server、location、if

regex：

* `~ `为区分大小写匹配

* `~* `为不区分大小写匹配

* `!~`和`!~*`分别为区分大小写不匹配及不区分大小写不匹配

文件及目录匹配：

* `-f`和`!-f`用来判断是否存在文件

* `-d`和`!-d`用来判断是否存在目录

* `-e`和`!-e`用来判断是否存在文件或目录

* `-x`和`!-x`用来判断文件是否可执行

Flag参数：

| 标记符号  | 说明                                                         |
| --------- | ------------------------------------------------------------ |
| last      | 终止在本location块中处理接收到的URI，并将此处重写的URI作为新的URI使用其他location进行处理。（只是终止当前location的处理）【如果没有匹配到，会继续向下匹配】 |
| break     | 将此处重写的URI作为一个新的URI在当前location中继续执行，并不会将新的URI转向其他location。【如果没有匹配到，则不再向下匹配，直接返回结果404】 |
| redirect  | 将重写后的URI返回个客户端，状态码是302，表明临时重定向，主要用在replacement字符串不以“http://”，“ https://”或“ $scheme” 开头；【地址栏会显示跳转后的地址】 |
| permanent | 将重写的URI返回客户端，状态码为301,指明是永久重定向；【地址栏会显示跳转后的地址】 |


### 示例

示例一（常用301跳转）：

```bash
# 修改配置文件vhost1.conf
server {
            listen 80;
            server_name   vhost1.com;
            rewrite   ^/(.*)     http://www.vhost1.com/$1 permanent;
 }
    server {
        listen       80;
        server_name  www.vhost1.com;
        location / {
            root   /usr/share/nginx/html/vhost1;
            index  index.html index.htm;
        }
       error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
 }
```

示例二（域名新旧跳转）：

```bash
server
{
 listen 80;
 server_name www.old.com;
 rewrite "^/(.*)$" http://www.new.com/$1;
}
```

示例三（跳转站外网页）：

```bash
 server {
        listen       80;
        server_name  vhost2.com;
        location / {
           root   /usr/share/nginx/html/vhost2;
            index  index.html index.htm;
        }
        error_page 404 /404.html;
            location = /40x.html {
        }
        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    if ( $http_host ~* "^(.*)") {
        set $domain $1;
        rewrite ^(.*) http://www.baidu.com break;
    }
 }
```

示例四（自动将http跳转到https）：

```bash
location / {
       root /usr/share/nginx/html;
       index index.html;
       if ( $scheme = http ) {
           rewrite  ^/(.*)  https://www.xxx.com/$1 ;    
       }
   }
   # 指定网页跳转https
   location /login {
       root /usr/share/nginx/html;
       index index.html;
       if ( $scheme = http ) {
           rewrite / https://www.xxx.com/login permanent;
       }
       auth_basic "input password";
       auth_basic_user_file /apps/nginx/conf/.htpasswd;
   }
```

示例五（判断资源是否存在）：

```bash
location / {
       root  /usr/share/nginx/html;
       index index.html;
       if ( !-f $request_filename ) {
           rewrite (.*) http://www.xxx.com/index.html;
       }
   }
   # 资源不存在则跳往首页
```

示例六（根据用户浏览器跳转指定目录）：

```bash
# 如果用户使用的是IE浏览器则跳转至nginx-ie目录中去
if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$  /nginx-ie/$1 break;
}
```

示例七（资源防盗链）：

```bash
location /images {
       root /data/nginx/pc;
       valid_referers none blocked server_names *.example.com example.* www.example.org/galleries/
               ~\.google\.;			 #当访问/images下的资源时，只有指定的这些才可以访问
       if ( $invalid_referer ) {     #如果访问资源的网站不是从上面指定的搜索引擎跳转过来的，则拒绝访问，并且返回状态码403
           return 403;
           rewrite ^/ http://xxx.com/daolian.png;
       }
   }
# ---
location ~* .(gif|jpg|png|swf|flv)$ {
valid_referers none blocked server_names *.example.com example.* www.example.org/galleries/
               ~\.google\.;
if ($invalid_referer) {
return 403;
}
}
```

### 参考链接

* NGINX内置变量：http://www.cnphp.info/nginx-embedded-variables-lasted-version.html
* ngx_http_rewrite_module：http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite
* ngx_http_referer_module：http://nginx.org/en/docs/http/ngx_http_referer_module.html