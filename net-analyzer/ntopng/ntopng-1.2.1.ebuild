# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools pax-utils user 

DESCRIPTION="Network traffic analyzer with web interface"
HOMEPAGE="http://www.ntop.org/products/ntop/"
SRC_URI="mirror://sourceforge/ntop/${P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="net-libs/libpcap
	dev-lang/luajit:2
	net-analyzer/rrdtool
	net-libs/zeromq
	dev-libs/json-c
	dev-db/sqlite:3
	dev-libs/geoip
	dev-libs/hiredis"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup ntopng
	enewuser ntopng -1 -1 /var/lib/ntopng ntopng
}

src_prepare() {
	sed -i -E 's|(MAN_DIR=\$INSTALL_DIR)$|\1/share|' configure.ac || die
	eautoreconf

	sed -i '/^INSTALL_DIR=/iDEST_DIR=' Makefile.in || die
	sed -i -E 's/^((INSTALL|MAN)_DIR=)/\1$(DEST_DIR)/' Makefile.in || die
}

src_configure() {
	econf --mandir=/usr/share/man
}

src_compile() {
	emake geoip
	emake
}

src_install() {
	emake DEST_DIR="${D}" install

	keepdir /var/lib/ntopng &&
		fowners ntopng:ntopng /var/lib/ntopng &&
		fperms 740 /var/lib/ntopng

	newinitd "${FILESDIR}"/ntopng.initd ntopng
	newconfd "${FILESDIR}"/ntopng.conf ntopng

	pax-mark -m "${D}"/usr/bin/ntopng
}
