FROM alpine:3.11

ARG TZ="UTC"
ARG V2RAY_VERSION=v4.22.1
ARG V2RAY_DOWNLOAD_URL=https://github.com/v2ray/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip
ARG CADDY_DOWNLOAD_URL=https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.14/caddy2_beta14_linux_amd64

ENV domain=loaclhost
ENV uuid=2074ccef-0492-4150-b140-70088e75ff96
ENV v2ray_path=/request
ENV reverse_proxy_url=https://www.v2ray.com

RUN apk --no-cache add tzdata ca-certificates nginx unzip acme.sh supervisor \
    && mkdir -p /tmp/v2ray \
    && wget -O /tmp/v2ray/v2ray.zip ${V2RAY_DOWNLOAD_URL} \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /tmp/v2ray/v2ctl /usr/local/bin/ \
    && chmod +x /usr/local/bin/v2ray /usr/local/bin/v2ctl \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /tmp/*

CMD ["/bin/sh", "/entrypoint.sh"]
