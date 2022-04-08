# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Various shell scripts for CLN (Core Lightning / c-lightning)."
HOMEPAGE="https://github.com/kristapsk/cln-scripts"
SRC_URI=""
EGIT_REPO_URI="https://github.com/kristapsk/cln-scripts.git"
EGIT_BRANCH="master"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="
	${DEPEND}
	app-misc/jq
	net-p2p/c-lightning
"
BDEPEND=""

src_install() {
	dodir /opt/cln-scripts
	exeinto /opt/cln-scripts
	doexe cln-*.sh

	dosym /opt/cln-scripts/cln-channelbalance.sh /usr/bin/cln-channelbalance
	dosym /opt/cln-scripts/cln-feereport.sh /usr/bin/cln-feereport
	dosym /opt/cln-scripts/cln-random-traffic-gen.sh /usr/bin/cln-random-traffic-gen
	dosym /opt/cln-scripts/cln-walletbalance.sh /usr/bin/cln-walletbalance
}
