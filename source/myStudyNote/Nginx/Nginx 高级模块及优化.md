# Nginx 高级模块及优化 

## ngx_stream_core_module

默认情况下该模块不会自动安装,需要在编译是使用with来安装. 检查当前nginx是否安装有该模块,`rpm -qa nginx | grep mod-stream`

Example Configuration

> ```
> worker_processes auto;
> 
> error_log /var/log/nginx/error.log info;
> 
> events {
>     worker_connections  1024;
> }
> 
> stream {
>     upstream backend {
>         hash $remote_addr consistent;
> 
>         server backend1.example.com:12345 weight=5;
>         server 127.0.0.1:12345            max_fails=3 fail_timeout=30s;
>         server unix:/tmp/backend3;
>     }
> 
>     upstream dns {
>        server 192.168.0.1:53535;
>        server dns.example.com:53;
>     }
> 
>     server {
>         listen 12345;
>         proxy_connect_timeout 1s;
>         proxy_timeout 3s;
>         proxy_pass backend;
>     }
> 
>     server {
>         listen 127.0.0.1:53 udp reuseport;
>         proxy_timeout 20s;
>         proxy_pass dns;
>     }
> 
>     server {
>         listen [::1]:12345;
>         proxy_pass unix:/tmp/stream.socket;
>     }
> }
> ```