# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Various shell scripts for Bitcoin Core (bitcoind or bitcoin-qt)."
HOMEPAGE="https://github.com/kristapsk/bitcoin-scripts"
SRC_URI=""
EGIT_REPO_URI="https://github.com/kristapsk/bitcoin-scripts.git"
EGIT_BRANCH="master"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="-test"

DEPEND="
	app-misc/jq
	>=app-shells/bash-4
	net-p2p/bitcoin-cli
	test? (
		dev-util/bats
		net-p2p/bitcoind
	)
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_test() {
	if use test; then
		cd "${S}"/tests || die
		./test_all.sh
		cd "${S}"/tests/functional || die
		./test_all.sh
	fi
}

src_install() {
	dodir /opt/bitcoin-scripts
	insinto /opt/bitcoin-scripts
	doins inc.common.sh
	doins donation-address.txt.asc
	doins README.md
	exeinto /opt/bitcoin-scripts
	doexe blockheightat.sh
	doexe checktransaction.sh
	doexe estimatesmartfee.sh
	doexe fake-coinjoin.sh
	doexe listpossiblecjtxids.sh
	doexe randbtc.sh
	doexe ricochet-send-from.sh
	doexe ricochet-send.sh
	doexe timetoblocks.sh
	doexe whitepaper.sh

	dosym /opt/bitcoin-scripts/blockheightat.sh /usr/bin/bc-blockheightat
	dosym /opt/bitcoin-scripts/checktransaction.sh /usr/bin/bc-checktransaction
	dosym /opt/bitcoin-scripts/estimatesmartfee.sh /usr/bin/bc-estimatesmartfee
	dosym /opt/bitcoin-scripts/fake-coinjoin.sh /usr/bin/bc-fake-coinjoin
	dosym /opt/bitcoin-scripts/listpossiblecjtxids.sh /usr/bin/bc-listpossiblecjtxids
	dosym /opt/bitcoin-scripts/randbtc.sh /usr/bin/bc-randbtc
	dosym /opt/bitcoin-scripts/ricochet-send-from.sh /usr/bin/bc-ricochet-send-from
	dosym /opt/bitcoin-scripts/ricochet-send.sh /usr/bin/bc-ricochet-send
	dosym /opt/bitcoin-scripts/timetoblocks.sh /usr/bin/bc-timetoblocks
	dosym /opt/bitcoin-scripts/whitepaper.sh /usr/bin/bc-whitepaper
}
