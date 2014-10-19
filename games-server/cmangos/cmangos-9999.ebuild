# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils git-r3 autotools cmake-utils user
DESCRIPTION="Full featured World of Warcraft suite"
HOMEPAGE="http://getmangos.com"
SRC_URI=""
CATEGORY="games-server"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+ace tbb +scriptdev2 tools vehicle"

RDEPEND="dev-libs/openssl
		sys-libs/zlib
		ace? ( >=dev-libs/ace-5.6.3 )
		tbb? ( dev-cpp/tbb )
		dev-db/mysql"
DEPEND="${RDEPEND}
	dev-vcs/git"

MANGOS_REPO_URI="git://github.com/cmangos/mangos-wotlk.git"
SD2_REPO_URI="git://github.com/scriptdev2/scriptdev2.git"
#ACID_REPO_URI="git://github.com/scriptdev2/acid.git"

EGIT_REPO_URI=$MANGOS_REPO_URI
OUT=/opt/mangos

src_unpack() {
	git-r3_src_unpack

	if use scriptdev2; then
		EGIT_CHECKOUT_DIR="${S}/src/bindings/ScriptDev2" EGIT_REPO_URI=$SD2_REPO_URI git-r3_src_unpack || die
	fi
}

pkg_setup() {
	#enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/${PN}
	enewuser realmd -1 -1 /var/lib/${PN} ${PN}
}


src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=$OUT
		-DDEBUG=0
		-DPCH=1
		$(cmake-utils_use ace ACE_USE_EXTERNAL)
		$(cmake-utils_use tbb TBB_USE_EXTERNAL)
	)

	#[ -d $OUT ] || mkdir $OUT
	use scriptdev2 && mycmakeargs+=( -DINCLUDE_BINDINGS_DIR=ScriptDev2 )

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	chmod -x ${D}${OUT}/lib/libmangosscript.so
	dodoc ${S}/doc/script_commands.txt
	dodoc ${S}/doc/AuctionHouseBot.txt
	dodoc ${S}/doc/EventAI.txt

	dodir /var/lib/${PN}
	keepdir /var/lib/${PN}

	dodir /var/lib/${PN}
	keepdir /var/lib/${PN}

	mv ${D}${OUT}/etc/realmd.conf.dist ${D}${OUT}/etc/realmd.conf
	mv ${D}${OUT}/etc/mangosd.conf.dist ${D}${OUT}/etc/mangosd.conf
	mv ${D}${OUT}/etc/scriptdev2.conf.dist ${D}${OUT}/etc/scriptdev2.conf
	mv ${S}/src/game/AuctionHouseBot/ahbot.conf.dist.in ${D}${OUT}/etc/ahbot.conf

	mkdir -p ${D}${OUT}/usr/share/mangos
	cp -R ${S}/sql ${D}${OUT}/usr/share/mangos
}
