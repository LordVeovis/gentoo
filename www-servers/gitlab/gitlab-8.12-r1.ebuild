# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit git-r3 user
DESCRIPTION="Gitlab"
HOMEPAGE="https://gitlab.com"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="nginx"

DEPEND=">=dev-lang/ruby-2.1
	>=dev-vcs/git-2.7.4
	>=dev-db/redis-2.8
	dev-ruby/bundler"
RDEPEND="${DEPEND}
	=www-servers/gitlab-shell-3.6.3*
	=www-servers/gitlab-workhorse-0.8.2*"

EGIT_REPO_URI='https://gitlab.com/gitlab-org/gitlab-ce.git'
EGIT_BRANCHES='8-12-stable'

pkg_setup() {
	enewgroup git
	enewuser ${PN} -1 -1 / git
}

src_compile() {
	pushd ${S}
	bundle install --without postgres development test --deployment
	#bundle exec rake assets:clean assets:precompile cache:clear RAILS_ENV=production
	popd
}

src_install() {
	local installdir
	installdir=/opt/${PN}
	logdir=/var/log/gitlab
	conf_unicorn=${D}/etc/${PN}/unicorn.rb

	sed -i -e "s!/home/git/gitlab-shell!/opt/gitlab-shell!" "${S}/config/gitlab.yml.example"
	sed -i -e "s!secret_file: /home/git/gitlab/.gitlab_shell_secret!secret_file: /etc/gitlab/.gitlab_shell_secret!" "${S}/config/gitlab.yml.example"

	sed -i -e "s!^sidekiq_pidfile=.*!sidekiq_pidfile=/run/gitlab/sidekiq.pid!" ${S}/bin/background_jobs
	sed -i -e "s!^sidekiq_logfile=.*!sidekiq_logfile=/var/log/gitlab/sidekiq.log!" ${S}/bin/background_jobs

	dodir "$installdir"
	dodir "$installdir/public/assets"
	dodir "$installdir/public/uploads"
	rm -R ${S}/.git*
	cp -rT ${S} ${D}/${installdir}
	fowners git:git ${installdir}/tmp
	fowners git:git ${installdir}/log
	fowners git:git ${installdir}
	fowners git:git ${installdir}/db/schema.rb
	fowners git:git ${installdir}/public/{assets,uploads}
	fperms 700 ${installdir}/public/uploads

	keepdir $logdir
	fowners git:git $logdir
	fperms 750 $logdir

	keepdir /etc/${PN}
	insinto /etc/${PN}
	newins config/unicorn.rb.example unicorn.rb
	sed -i -e "s!^pid.*!pid \"/run/gitlab/unicorn.pid\"!" "$conf_unicorn"
	sed -i -e "s!/home/git/gitlab/log!/var/log/gitlab!" "$conf_unicorn"
	sed -i -e "s!/home/git/gitlab/tmp/sockets!/run/gitlab!" "$conf_unicorn"
	sed -i -e "s!/home/git/gitlab!$installdir!" "$conf_unicorn"

	if use nginx; then
		nginx_dir=/etc/nginx
		nginx_conf=${D}$nginx_dir/gitlab.conf

		insinto /etc/nginx
		newins lib/support/nginx/gitlab-ssl gitlab.conf

		sed -i -e "s!/home/git/gitlab/tmp/sockets!/run/gitlab!" $nginx_conf
	fi

	newinitd "${FILESDIR}/initd-sidekiq" gitlab-sidekiq
	newinitd "${FILESDIR}/initd-unicorn" gitlab-unicorn
	newconfd "${FILESDIR}/confd-unicorn" gitlab-unicorn
	newconfd "${FILESDIR}/confd-sidekiq" gitlab-sidekiq
}
