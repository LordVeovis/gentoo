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
IUSE=""

DEPEND="dev-db/sqlite:3
	dev-lang/luajit:2
	dev-libs/geoip
	dev-libs/glib:2
	dev-libs/libxml2
	>=net-analyzer/rrdtool-1.4.8[graph]
	net-libs/libpcap
	dev-python/pyzmq
	=net-libs/libndpi-9999[json-c]
	dev-libs/json-c
	>=net-libs/zeromq-4.1.3
	dev-libs/hiredis
	virtual/mysql
	dev-libs/openssl
	sys-libs/zlib
	dev-libs/libnl
	net-misc/curl
	dev-libs/glib"
RDEPEND="${DEPEND}
	dev-db/redis"

EGIT_REPO_URI='git://github.com/ntop/ntopng.git'
EGIT_BRANCH='dev'

src_prepare() {
	# clang 3.5 does not support thoses flags
	filter-flags -msahf -mabm -mfxsr
	epatch "${FILESDIR}/${P}-fix-configure.ac.patch"
	cat "${S}/configure.seed" | sed "s/@VERSION@/${PV}/g" | sed "s/@SHORT_VERSION@/${PV}/g" > "${S}/configure.ac"
	#epatch "${FILESDIR}/${PN}-2.0-dont-build-ndpi.patch"
	#epatch "${FILESDIR}/${PN}-2.0-include-sys-types.patch"
	#epatch "${FILESDIR}/${P}-fix-mysql-detection.patch"
	eautoreconf
}

src_configure() {
	cd "${S}"
	econf
}

src_compile() {
	default

	emake geoip
}

src_install() {
	SHARE_NTOPNG_DIR="${EPREFIX}/usr/share/${PN}"
	dodir ${SHARE_NTOPNG_DIR}
	insinto ${SHARE_NTOPNG_DIR}
	doins -r httpdocs
	doins -r scripts
	rm "${D}"/usr/share/ntopng/scripts/lua/modules/i18n
	rm "${D}"/usr/share/ntopng/scripts/lua/modules/resty
	cp -R "${S}"/third-party/i18n.lua-master/i18n "${D}"/usr/share/ntopng/scripts/lua/modules/i18n
	cp -R "${S}"/third-party/lua-resty-template-master/lib/resty "${D}"/usr/share/ntopng/scripts/lua/modules/resty

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
