#!/bin/sh
# usage: sh switch-traffic.sh blue|green
set -eu
COLOR="$1"
CONF_DIR="${BG_DIR:-/var/lib/jenkins/bluegreen}/conf"
mkdir -p "$CONF_DIR"
cat > "$CONF_DIR/default.conf.tmp" <<EOF
server {
    listen 80;
    resolver 127.0.0.11 valid=2s;
    add_header X-Active-Color $COLOR always;
    location / {
        set \$upstream http://app-$COLOR:8000;
        proxy_pass \$upstream;
    }
}
EOF
mv "$CONF_DIR/default.conf.tmp" "$CONF_DIR/default.conf"
