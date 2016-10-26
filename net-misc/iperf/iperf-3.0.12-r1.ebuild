# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils flag-o-matic

DESCRIPTION="A TCP, UDP, and SCTP network bandwidth measurement tool"
LICENSE="BSD"
SLOT="3"
HOMEPAGE="https://github.com/esnet/iperf/"
SRC_URI="https://codeload.github.com/esnet/${PN}/tar.gz/${PV} -> ${P}.tar.gz"
KEYWORDS="amd64 ~arm hppa ~mips ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint"
IUSE="static-libs"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.0.5-flags.patch
	epatch "${FILESDIR}"/${PN}-3.0.5-includes.patch
	eautoreconf
}

src_configure() {
	# Defines _GNU_SOURCE to correctly define struct tcp_info
	use elibc_musl && append-cflags -D__MUSL__ -D_GNU_SOURCE

	econf $(use_enable static-libs static)
}

src_install() {
	default
	prune_libtool_files
}
