#!/sbin/openrc-run
# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PIDFILE=/var/run/ntopng/ntopng.pid
NTOPNG_USER=${NTOPNG_USER:-ntopng}
NTOPNG_GROUP=${NTOPNG_GROUP:-ntopng}

depend() {
	need net redis
}

start() {
	ebegin "Starting ntopng"
	checkpath -d -m 0775 -o ${NTOPNG_USER}:${NTOPNG_GROUP} $(dirname ${PIDFILE})
	start-stop-daemon --start --quiet \
		--background \
		-p "$PIDFILE" \
		--exec /usr/bin/ntopng -- \
		-i $INTERFACE \
		-U $NTOPNG_USER \
		-r $REDIS \
		-G "$PIDFILE" \
		$NTOPNG_OPTS
	eend $?
}

stop() {
	ebegin "Shutting down ntopng"
	start-stop-daemon --stop --quiet \
		--exec /usr/bin/ntopng \
		-p "$PIDFILE"
	eend $?
}
