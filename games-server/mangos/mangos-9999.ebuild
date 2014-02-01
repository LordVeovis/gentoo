# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils git-r3 autotools cmake-utils
DESCRIPTION="Full featured World of Warcraft suite"
HOMEPAGE="http://getmangos.com"
SRC_URI=""
CATEGORY="games-server"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="+ace tbb +scriptdev2 mysql postgres tools vehicle"

RDEPEND="postgres? ( virtual/postgresql-server )
		mysql? ( >=virtual/mysql-4.1 )
		dev-libs/openssl
		sys-libs/zlib
		dev-vcs/git
		ace? ( >=dev-libs/ace-5.6.3 )
		tbb? ( dev-cpp/tbb )"
DEPEND="${RDEPEND}"

MANGOS_REPO_URI="git://github.com/mangos/mangos.git"
SD2_REPO_URI="https://github.com/scriptdev2/scriptdev2"

EGIT_REPO_URI=$MANGOS_REPO_URI

src_unpack() {
	git-r3_src_unpack

	if use scriptdev2; then
		S="${S}/src/bindings/ScriptDev2" EGIT_REPO_URI=$SD2_REPO_URI git_src_unpack || die
		local PATCHES_DIR="${S}/src/bindings/ScriptDev2/patches"
		local FILE=$(ls ${PATCHES_DIR} | sort -f -r | awk "NR == 1")

		EPATCH_OPTS="-d ${S}" EPATCH_FORCE="yes" epatch	"${PATCHES_DIR}/${FILE}"
	fi
}

pkg_setup() {
	#enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/${PN}
	enewuser realmd -1 -1 /var/lib/${PN} ${PN}
}


src_configure() {
	mkdir ${S}/build
	export ECONF_SOURCE="${S}"
	cd ${S}/build

	mycmakeargs=(
		-DPREFIX=/opt/mangos
		-DCMAKE_INSTALL_PREFIX=
		-DDEBUG=0
		-DPCH=0)

	use ace && mycmakeargs+=( -DACE_USE_EXTERNAL=1 ) || mycmakeargs+=( -DACE_USE_EXTERNAL=0 )
	use tbb && mycmakeargs+=( -DTBB_USE_EXTERNAL=1 ) || mycmakeargs+=( -DTBB_USE_EXTERNAL=0 )

	cmake-utils_src_configure
}

src_install() {
	cd $CMAKE_BUILD_DIR

	#sed -i 's/^prefix = /prefix = ${DESTDIR}/g' ${S}/objdir/dep/tbb/Makefile
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ${S}/AUTHORS
	dodoc ${S}/NEWS
	dodoc ${S}/ChangeLog
	dodoc ${S}/WARNING
	dodoc ${S}/doc/script_commands.txt
	dodoc ${S}/doc/AuctionHouseBot.txt

	dodir /var/lib/${PN}
	keepdir /var/lib/${PN}

	dodir /var/lib/${PN}
	keepdir /var/lib/${PN}

	mv ${D}/etc/realmd.conf.dist ${D}/etc/realmd.conf
	mv ${D}/etc/mangosd.conf.dist ${D}/etc/mangosd.conf
	mv ${D}/etc/scriptdev2.conf.dist ${D}/etc/scriptdev2.conf
	mv ${S}/src/game/AuctionHouseBot/ahbot.conf.dist.in ${D}/etc/ahbot.conf

	cp -R ${S}/sql ${D}/usr/share/mangos
}
