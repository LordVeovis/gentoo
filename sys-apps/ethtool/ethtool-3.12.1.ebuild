# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ethtool/ethtool-3.12.1.ebuild,v 1.10 2014/01/26 12:18:24 ago Exp $

EAPI="4"
inherit base

DESCRIPTION="Utility for examining and tuning ethernet-based network interfaces"
HOMEPAGE="http://www.kernel.org/pub/software/network/ethtool/"
SRC_URI="mirror://kernel/software/network/ethtool/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86"

DEPEND="app-arch/xz-utils"

PATCHES=( "${FILESDIR}"/"${P}"-includes.patch )
