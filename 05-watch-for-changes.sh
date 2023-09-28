#!/bin/ash -e

cp /etc/nginx/nginx.conf.init /etc/nginx/nginx.conf
ls -la /etc/nginx/ >&2
rm -f /etc/nginx/conf.d/*
cp -r /etc/nginx/conf.init/* /etc/nginx/conf.d/

lastChange=$(stat -c %y /etc/letsencrypt/live/domain/fullchain.pem || true)
if [ -n "$lastChange" ]; then
	for file in /etc/nginx/conf.d/*.conf.ssl; do
		mv $file ${file%.ssl}
	done
	sleep=86400
else
	sleep=60
fi

while true; do
	sleep $sleep

	change=$(stat -c %y /etc/letsencrypt/live/domain/fullchain.pem || true)

	if [ "$change" = "$lastChange" ]; then
		continue
	fi

	if ls /etc/nginx/conf.d/*.conf.ssl; then
		for file in /etc/nginx/conf.d/*.conf.ssl; do
			mv $file ${file%.ssl}
		done
		sleep=86400
	fi

	lastChange=$change

	nginx -s reload

done &

