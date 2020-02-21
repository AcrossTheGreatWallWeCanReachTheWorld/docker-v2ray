FROM alpine:3.11

ARG TZ="UTC"
ARG V2RAY_VERSION=v4.22.1
ARG V2RAY_DOWNLOAD_URL=https://github.com/v2ray/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip
ARG CADDY_DOWNLOAD_URL=https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_amd64.tar.gz

RUN apk --no-cache add tzdata ca-certificates unzip supervisor \
    && mkdir -p /tmp/v2ray \
    && wget -O /tmp/v2ray/v2ray.zip ${V2RAY_DOWNLOAD_URL} \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /tmp/v2ray/v2ctl /usr/local/bin/ \
    && chmod +x /usr/local/bin/v2ray /usr/local/bin/v2ctl \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /tmp/*

RUN wget -O - $CADDY_DOWNLOAD_URL | tar -xzvC /usr/local/bin caddy

ENV DOMAIN=0.0.0.0
ENV UUID=2074ccef-0492-4150-b140-70088e75ff96
ENV V2RAY_PATH=/request
ENV REVERSE_PROXY_URL=https://www.v2ray.com

ADD entrypoint.sh /
VOLUME /root/.caddy /var/log
WORKDIR /root
EXPOSE 443 80
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
