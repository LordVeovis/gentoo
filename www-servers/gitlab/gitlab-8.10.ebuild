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
IUSE=""

DEPEND="=dev-lang/ruby-2.1*
	>=dev-vcs/git-2.7.4
	>=dev-db/redis-2.8"
RDEPEND="${DEPEND}
	=www-servers/gitlab-shell-2.7.2
	=www-servers/gitlab-workhorse-0.7.8"

EGIT_REPO_URI='https://gitlab.com/gitlab-org/gitlab-ce.git'
EGIT_BRANCH='8-10-stable'

src_install() {
	local installdir
	installdir=/opt/gitlab

	dodir "$installdir"
	rm -R ${S}/.git*
	cp -r ${S} ${D}/${installdir}/${PN}

	newinitd "${FILESDIR}/initd-sidekiq" gitlab-sidekiq
	newinitd "${FILESDIR}/initd-unicorn" gitlab-unicorn
}
