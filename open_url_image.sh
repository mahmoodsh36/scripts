#!/usr/bin/env sh

mkdir /tmp/online_images/ 2>/dev/null

random_filename=$(head -c 100 /dev/urandom | tr -dc A-Za-z0-9)

url=$(echo -n "$1" | cut -d '?' -f1 | tr -d '\n')
curl -L -o /tmp/online_images/$random_filename "$url"
sxiv /tmp/online_images/$random_filename