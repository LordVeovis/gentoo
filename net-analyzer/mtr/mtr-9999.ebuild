# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools eutils fcaps flag-o-matic git-r3

DESCRIPTION="My TraceRoute, an Excellent network diagnostic tool"
HOMEPAGE="http://www.bitwizard.nl/mtr/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="bash-completion gtk +ipinfo ipv6 +ncurses"

RDEPEND="
	sys-libs/ncurses:0=
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
	)
"
DEPEND="
	${RDEPEND}
	sys-devel/autoconf
	virtual/pkgconfig
"
REQUIRED_USE="^^ ( gtk ncurses )"

EGIT_REPO_URI='https://github.com/traviscross/mtr.git'

DOCS=( AUTHORS FORMATS NEWS README SECURITY TODO )
FILECAPS=( cap_net_raw /usr/sbin/mtr )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable bash-completion) \
		$(use_enable ipv6) \
		$(use_with gtk) \
		$(use_with ncurses) \
		$(use_with ipinfo)
}
