# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils user flag-o-matic

DESCRIPTION="Network traffic analyzer with web interface"
HOMEPAGE="http://www.ntop.org/"
SRC_URI="mirror://sourceforge/ntop/${PN}/${P}-stable.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-db/sqlite:3
	dev-lang/luajit:2
	dev-libs/geoip
	dev-libs/glib:2
	dev-libs/libxml2
	net-analyzer/rrdtool
	net-libs/libpcap
	dev-python/pyzmq
	net-libs/libndpi"
RDEPEND="${DEPEND}
	dev-db/redis"

src_unpack() {
	default

	mv ${WORKDIR}/${P}-stable ${S}
}

src_prepare() {
	# clang 3.5 does not support thoses flags
	filter-flags -msahf -mabm -mfxsr
	cat "${S}/configure.seed" | sed "s/@VERSION@/${PV}/g" | sed "s/@SHORT_VERSION@/${PV}/g" > "${S}/configure.ac"
	#epatch "${FILESDIR}/${PN}-2.0-dont-build-ndpi.patch"
	#epatch "${FILESDIR}/${PN}-2.0-include-sys-types.patch"
	epatch "${FILESDIR}/${P}-no-ndpi.patch"
	epatch "${FILESDIR}/${P}-fix-mysql-detection.patch"
	eautoreconf
}

src_configure() {
	cd "${S}"
	econf
}

src_compile() {
	emake all
}

src_install() {
	SHARE_NTOPNG_DIR="${EPREFIX}/usr/share/${PN}"
	dodir ${SHARE_NTOPNG_DIR}
	insinto ${SHARE_NTOPNG_DIR}
	doins -r httpdocs
	doins -r scripts

	exeinto /usr/bin
	doexe ${PN}
	doman ${PN}.8

	newinitd "${FILESDIR}/ntopng.init.d" ntopng
	newconfd "${FILESDIR}/ntopng.conf.d" ntopng

	dodir "/var/lib/ntopng"
	fowners ntopng "${EPREFIX}/var/lib/ntopng"
}

pkg_setup() {
	enewuser ntopng
}

pkg_postinst() {
	elog "ntopng default creadential are user='admin' password='admin'"
}
