#!/bin/bash
yum install -y nginx

cat > /etc/nginx/conf.d/toptal.conf << 'NGINXEOF'
upstream web_backend {
    server 10.0.10.186:31147;
    server 10.0.20.178:31147;
}

upstream api_backend {
    server 10.0.10.186:31938;
    server 10.0.20.178:31938;
}

upstream grafana_backend {
    server 10.0.10.186:32010;
    server 10.0.20.178:32010;
}

server {
    listen 80;
    server_name _;

    location /api {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://web_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 3000;
    server_name _;

    location / {
        proxy_pass http://grafana_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

systemctl enable nginx
systemctl start nginx
