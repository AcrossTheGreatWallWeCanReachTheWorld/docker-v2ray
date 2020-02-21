# docker-v2ray

A simple v2ray+ws+tls server
run:
```
docker run --name v2ray -d --restart=always -p 80:80 -p 433:433 -e DOMAIN=<DOMAIN> -e UUID=<UUID> -e V2RAY_PATH=<V2RAY_PATH> -e REVERSE_PROXY_URL=<REVERSE_PROXY_URL> acrossthegreatwall/v2ray
```
log:
```
docker logs v2ray
```
