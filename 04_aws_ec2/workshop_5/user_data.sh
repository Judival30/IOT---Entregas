#!/bin/bash

apt update
apt install -y nginx

systemctl enable nginx
systemctl start nginx

HOSTNAME_EC2=$(hostname)

cat > /var/www/html/index.html <<EOFHTML
<h1>Servidor provisionado automaticamente</h1>
<p>EC2 + User Data</p>
<p>Estudiante: Juan Diego Valencia</p>
<p>Hostname: ${HOSTNAME_EC2}</p>
EOFHTML
