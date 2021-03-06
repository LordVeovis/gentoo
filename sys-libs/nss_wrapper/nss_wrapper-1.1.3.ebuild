# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-multilib flag-o-matic

DESCRIPTION="A wrapper for the user, group and hosts NSS API"
HOMEPAGE="https://cwrap.org/nss_wrapper.html"
SRC_URI="https://ftp.samba.org/pub/cwrap/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~hppa ia64 ppc ppc64 x86"
IUSE="test"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	default

	use elibc_musl && epatch "${FILESDIR}"/${P}-musl-fixes.patch
}

# Work around a problem with >=dev-util/cmake-3.3.0 (bug #558340)
# Because of this we cannot use cmake-multilib_src_configure() here.
multilib_src_configure() {
	local mycmakeargs=( -DCMAKE_LIBRARY_PATH=/usr/$(get_libdir) )
	cmake-utils_src_configure
}
