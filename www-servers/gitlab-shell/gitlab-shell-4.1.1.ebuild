# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit git-r3 user
DESCRIPTION="Gitlab Shell"
HOMEPAGE="https://gitlab.com"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=dev-lang/ruby-2.1
	>=dev-vcs/git-2.8.4"
RDEPEND="${DEPEND}"

EGIT_REPO_URI='https://gitlab.com/gitlab-org/gitlab-shell.git'
EGIT_COMMIT="v${PV}"

GITLAB_USER=git
GITLAB_GROUP=git

pkg_setup() {
	enewgroup "$GITLAB_GROUP"
	enewuser "$GITLAB_USER" -1 -1 /home/"$GITLAB_USER" "$GITLAB_GROUP"
}

src_install() {
	local installdir
	installdir=/opt/${PN}

	dodir "$installdir"
	rm -R ${S}/.git*
	cp -a ${S}/. ${D}/${installdir}
	#rm -R ${D}/${install}/${PN}/.git*

	dosym /etc/gitlab/.gitlab_shell_secret ${installdir}/.gitlab_shell_secret
	fowners -h "${GITLAB_USER}:${GITLAB_GROUP}" /${installdir}/.gitlab_shell_secret
	#fperms 600 ${installdir}/.gitlab_shell_secret
}
