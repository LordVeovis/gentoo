# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/inspircd/inspircd-1.1.19.ebuild,v 1.6 2009/01/14 05:12:18 vapier Exp $

inherit eutils toolchain-funcs multilib autotools # subversion

EAPI="2"
DESCRIPTION="Denora"
HOMEPAGE="http://www.denorastats.org/"
SRC_URI="mirror://sourceforge/${PN}/denora-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="crypt thread mysql debug perl ssl"

RDEPEND="perl? dev-lang/perl
	mysql? ( virtual/mysql )
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}

src_prepare() {
	eautoreconf
}

src_configure() {
	# ./configure doesn't know --disable-gnutls, -ipv6 and -openssl options,
	# so should be used only --enable-like.
	local myconf=""
	!(use mysql) && myconf="--without-mysql "

	econf $myconf \
		$(use_enable crypt) \
		$(use_enable thread threading) \
		$(use_enable debug dmalloc) \
		$(use_enable perl) \
		$(use_with ssl) \
		--with-rungroup=denora \
		--with-bindir="/usr/bin" \
		--with-datadir="/var/lib/denora" \
		|| die "configure failed"

	sed -i 's/-g -ggdb //g' Makefile
	sed -i 's/^BINDEST=/BINDEST=$(DESTDIR)/g' Makefile
	sed -i 's/^DATDEST=/DATDEST=$(DESTDIR)/g' Makefile
	sed -i 's#^MODULE_PATH=.*$#MODULE_PATH=$(DESTDIR)/usr/lib/denora#g' Makefile
}

pkg_setup() {
	enewgroup denora
	enewuser denora -1 -1 /var/lib/denora denora
}

src_compile() {
	emake -j1 || die "emake failed"
}

src_install() {
	#dodoc Changes.* QUICKSTART.txt README
	dodir /usr/bin
	dodir /usr/lib/denora
	dodir /var/lib/denora
	dodir /var/lib/denora/languages
	dodir /var/lib/denora/modules
	dodir /var/lib/denora/modules/runtime

	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	keepdir "/var/lib/denora"
}
