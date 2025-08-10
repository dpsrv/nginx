#!/bin/ash -e

cp /etc/nginx/nginx.conf.init /etc/nginx/nginx.conf
ls -la /etc/nginx/ >&2
rm -f /etc/nginx/conf.d/* || true
cp -r /etc/nginx/conf.init/* /etc/nginx/conf.d/

function getLastChange() {
	find /etc/letsencrypt/live/domain/fullchain.pem /etc/nginx/conf.init/ -type f -exec stat -c %Y {} \;|sort|tail -1 || true
}

function updateConfigs() {
	cp -r /etc/nginx/conf.init/* /etc/nginx/conf.d/
	if ls /etc/nginx/conf.d/*.conf.ssl; then
		for file in /etc/nginx/conf.d/*.conf.ssl; do
			mv $file ${file%.ssl}
		done
	fi
	sleep=86400
}

lastChange=$(getLastChange)
if [ -n "$lastChange" ]; then
	updateConfigs
else
	sleep=60
fi

while true; do
	sleep $sleep

	change=$(getLastChange)

	if [ "$change" = "$lastChange" ]; then
		continue
	fi

	updateConfigs

	lastChange=$change

	nginx -s reload

done &

