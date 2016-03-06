# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools linux-info linux-mod

DESCRIPTION="Kernel modules to access to leds on the apu motherboard"
HOMEPAGE="https://blog.kveer.fr"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

MODULE_NAMES='leds-apu(kernel/drivers/leds) apu-btn-gpio(kernel/drivers/gpio)'

pkg_setup() {
	kernel_is -lt 4 3 3 && die "${PN} requires kernel greater than 4.3.3."

	CONFIG_CHECK='LEDS_CLASS MODULES'
	ERROR_LEDS_CLASS='leds-apu requires LEDS_CLASS support in your kernel.'
	ERROR_MODULES='Nonmodular kernel detected. Build modular kernel.'

	linux-mod_pkg_setup
}

src_unpack() {
	mkdir "$S"
	cp "${FILESDIR}"/* "${S}/"
}

src_compile() {
	set_arch_to_kernel
	#KERNEL_DIR=$KERNEL_DIR emake 
	BUILD_PARAMS="KERNEL_DIR=$KERNEL_DIR CONFIG_DEBUG_SECTION_MISMATCH=y" linux-mod_src_compile
}

src_install() {
	BUILD_PARAMS="KERNEL_DIR=$KERNEL_DIR" linux-mod_src_install
}
