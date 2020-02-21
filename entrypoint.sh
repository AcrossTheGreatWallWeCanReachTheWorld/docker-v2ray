#!/bin/sh
# enviroments: DOMAIN, UUID, V2RAY_PATH, REVERSE_PROXY_URL
V2RAY_PORT=8080
set -e

mkdir -p /data/log
mkdir -p /data/caddy
ln -s /data/caddy ~/.caddy
cat << EOF > Caddyfile
$DOMAIN {
    gzip
    log /data/log/caddy.log
    timeouts none
    proxy / $REVERSE_PROXY_URL
    proxy /$V2RAY_PATH 127.0.0.1:$V2RAY_PORT {
        websocket
        header_upstream -Origin
    }
}
EOF

mkdir -p /data/log/v2ray
cat << EOF > v2ray.json
{
  "log" : {
    "access": "/data/log/v2ray/access.log",
    "error": "/data/log/v2ray/error.log",
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

(v2ray -config=v2ray.json
kill -SIGKILL "$(cat CADDY_PID)")&
echo "$!" > V2RAY_PID

(caddy -conf ./Caddyfile
kill -SIGKILL "$(cat V2RAY_PID)")&
echo "$!" > CADDY_PID

wait "$(cat V2RAY_PID)" "$(cat CADDY_PID)"
