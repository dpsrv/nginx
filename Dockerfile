FROM nginx:alpine3.18

RUN apk --update add inotify-tools \
	&& rm -rf /var/cache/apk/*

COPY 05-watch-for-changes.sh /docker-entrypoint.d/05-watch-for-changes.sh


