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
IUSE="-test"

DEPEND="
	test? ( dev-util/bats )
"
RDEPEND="
	${DEPEND}
	app-misc/jq
	|| ( net-p2p/c-lightning net-p2p/core-lightning )
"
BDEPEND=""

src_test() {
	if use test; then
		cd "${S}"/tests || die
		./test_all.sh
	fi
}

src_install() {
	dodir /opt/cln-scripts
	insinto /opt/cln-scripts
	doins inc.common.sh
	exeinto /opt/cln-scripts
	doexe cln-*.sh

	dosym /opt/cln-scripts/cln-amboss-ping.sh /usr/bin/cln-amboss-ping
	dosym /opt/cln-scripts/cln-channelbalance.sh /usr/bin/cln-channelbalance
	dosym /opt/cln-scripts/cln-feereport.sh /usr/bin/cln-feereport
	dosym /opt/cln-scripts/cln-prune-protector.sh /usr/bin/cln-prune-protector
	dosym /opt/cln-scripts/cln-random-traffic-gen.sh /usr/bin/cln-random-traffic-gen
	dosym /opt/cln-scripts/cln-walletbalance.sh /usr/bin/cln-walletbalance
}
