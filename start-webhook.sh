#!/bin/bash

docker run -d \
  --name provisioning-info \
  -p 4200:80 \
  -v /var/provisioning-info/:/usr/share/nginx/html/:ro \
  --restart unless-stopped \
  nginx:1.25.3
