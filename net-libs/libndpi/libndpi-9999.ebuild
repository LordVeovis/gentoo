# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils user flag-o-matic git-r3

DESCRIPTION="Network traffic analyzer with web interface"
HOMEPAGE="http://www.ntop.org/"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pic +json-c"

DEPEND="net-libs/libpcap
	dev-libs/libnl"
RDEPEND="${DEPEND}"

EGIT_REPO_URI='git://github.com/ntop/nDPI.git'
EGIT_BRANCH='dev'

src_prepare() {
	# clang 3.5 does not support thoses flags
	filter-flags -msahf -mabm -mfxsr
	sed -i -e 's/-static //' "${S}/example/Makefile.am"
	#cat "${S}/configure.seed" | sed "s/@VERSION@/${PV}/g" | sed "s/@SHORT_VERSION@/${PV}/g" > "${S}/configure.ac"
	#epatch "${FILESDIR}/${PN}-2.0-dont-build-ndpi.patch"
	#epatch "${FILESDIR}/${PN}-2.0-include-sys-types.patch"
	eautoreconf
}

src_configure() {
	econf \
		--enable-static=no \
		$(use_with pic) \
		$(use_enable json-c)
}
