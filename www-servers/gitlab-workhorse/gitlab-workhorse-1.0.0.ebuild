# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit git-r3 user
DESCRIPTION="Gitlab Workhorse"
HOMEPAGE="https://gitlab.com"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=dev-vcs/git-2.7.4
	>=dev-lang/go-1.5"
RDEPEND="${DEPEND}"

EGIT_REPO_URI='https://gitlab.com/gitlab-org/gitlab-workhorse.git'
EGIT_COMMIT="v${PV}"

pkg_setup() {
	enewgroup git
	enewuser ${PN} -1 -1 / git
}

src_install() {
	dobin gitlab-zip-cat
	dobin gitlab-zip-metadata
	dosbin gitlab-workhorse

	dodir /var/log/gitlab
	fowners root:git /var/log/gitlab

	newconfd "${FILESDIR}/conf.d" gitlab-workhorse
	newinitd "${FILESDIR}/init.d" gitlab-workhorse
}
