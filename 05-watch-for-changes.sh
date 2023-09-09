#!/bin/ash -e

cp /etc/nginx/nginx.conf.init /etc/nginx/nginx.conf
rm -f /etc/nginx/conf.d/*
cp /etc/nginx/conf.init/* /etc/nginx/conf.d/

lastChange=$(stat -c %y /etc/letsencrypt/live/domain/fullchain.pem || true)
if [ -n "$lastChange" ]; then
	mv /etc/nginx/conf.d/certbot.conf /etc/nginx/conf.d/certbot.conf.disabled
	mv /etc/nginx/conf.d/default.conf.disabled /etc/nginx/conf.d/default.conf
	sleep=86400
else
	sleep=60
fi


while true; do
	sleep $sleep

	change=$(stat -c %y /etc/letsencrypt/live/domain/fullchain.pem || true)

	if [ "$change" != "$lastChange" ]; then
		continue
	fi

	if [ -f /etc/nginx/conf.d/certbot.conf ]; then
		mv /etc/nginx/conf.d/certbot.conf /etc/nginx/conf.d/certbot.conf.disabled
		mv /etc/nginx/conf.d/default.conf.disabled /etc/nginx/conf.d/default.conf
		sleep=86400
	fi

	lastChange=$change

	nginx -s reload

done &

