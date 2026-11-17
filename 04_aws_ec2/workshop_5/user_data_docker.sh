#!/bin/bash

apt update
apt install -y docker.io

systemctl enable docker
systemctl start docker

mkdir -p /opt/web

cat > /opt/web/index.html <<'EOFHTML'
<h1>Contenedor desplegado con User Data</h1>
<p>EC2 + Docker + Nginx</p>
<p>Estudiante: Juan Diego Valencia</p>
EOFHTML

docker run -d --name web --restart always -p 80:80 \
    -v /opt/web/index.html:/usr/share/nginx/html/index.html:ro \
    nginx:alpine
