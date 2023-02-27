# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="File archiver with a high compression ratio."
HOMEPAGE="https://www.7-zip.org/"
SRC_URI="
	arm?	( https://www.7-zip.org/a/7z${PV/./}-linux-arm.tar.xz )
	arm64?	( https://www.7-zip.org/a/7z${PV/./}-linux-arm64.tar.xz )
	amd64?	( https://www.7-zip.org/a/7z${PV/./}-linux-x64.tar.xz )
	x86?	( https://www.7-zip.org/a/7z${PV/./}-linux-x86.tar.xz )
"

LICENSE="LGPL BSD-3"
SLOT="0"
KEYWORDS="~arm ~arm64 ~amd64 ~x86"
IUSE="static"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	exeinto /usr/bin
	if use static; then
		newexe 7zzs 7zz
	else
		doexe 7zz
	fi
}
