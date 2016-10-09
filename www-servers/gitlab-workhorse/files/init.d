#!/sbin/openrc-run
# GitLab 8.x init script for Gentoo Linux
# see https://github.com/gitlabhq/gitlabhq/blob/master/doc/installation.md

GITLAB_USER=git
GITLAB_WORKHORSE_BASE=/usr/sbin/gitlab-workhorse

start() {
	if [ ! -d $pid_path ]; then
		mkdir -p $pid_path
		chgrp git $pid_path
		chmod g=rwX $pid_path
	fi

	if [ ! -d $socket_path ]; then
		mkdir -p $socket_path
		chgrp git $socket_path
		chmod g=rwX $socket_path
	fi

	ebegin "Starting gitlab-workhorse"
	start-stop-daemon --start \
		--user "${GITLAB_USER}" \
		--pidfile "$gitlab_workhorse_pid_path" \
		--make-pidfile \
		--background \
		--env RAILS_ENV=$RAILS_ENV \
		--exec "${GITLAB_WORKHORSE_BASE}" -- $gitlab_workhorse_options
	eend $?
}
