#!/bin/sh
# enviroments: DOMAIN, UUID, V2RAY_PATH, REVERSE_PROXY_URL
V2RAY_PORT=8080
set -e

cat << 'EOF' > /etc/supervisord.conf
[supervisord]
nodaemon=true

[program:v2ray]
command=v2ray -config=/etc/v2ray/config.json
autorestart=true
priority=200
EOF

mkdir -p /etc/nginx/conf.d
cat << EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80 default_server;
    charset utf-8;

    location /$V2RAY_PATH {
    proxy_redirect off;
    proxy_pass http://127.0.0.1:$V2RAY_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$http_host;
    }

    location / {
    proxy_redirect off;
    proxy_pass $REVERSE_PROXY_URL;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

mkdir -p /etc/v2ray
cat << EOF > /etc/v2ray/config.json
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": $V2RAY_PORT,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$UUID",
          "level": 1,
          "alterId": 64
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/$V2RAY_PATH"
      }
    }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "outboundDetour": [
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.1/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        }
      ]
    }
  }
}
EOF

exec /usr/bin/supervisord -c /etc/supervisord.conf
