# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit desktop

DESCRIPTION="Configuration tool for MikroTik RouterOS"
HOMEPAGE="https://www.mikrotik.com"
SRC_URI="https://download.mikrotik.com/routeros/winbox/${PV}/winbox64.exe -> winbox64-${PV}.exe"

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="virtual/wine"

src_unpack() {
	mkdir -p ${S}
	cp ${DISTDIR}/${A} ${S}
}

src_install() {
	insinto /opt
	newins winbox64-${PV}.exe winbox64.exe
	dobin ${FILESDIR}/winbox
	domenu ${FILESDIR}/winbox.desktop
}
