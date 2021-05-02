# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 verify-sig

DESCRIPTION="Command-line JSON-RPC client specifically for interfacing with bitcoind"
HOMEPAGE="https://bitcoincore.org/"
SRC_URI="
	https://github.com/bitcoin/bitcoin/archive/v${PV}.tar.gz -> bitcoin-v${PV}.tar.gz
	verify-sig? ( https://github.com/kristapsk/bitcoin-core-patches/releases/download/v${KRISTAPSK_PV}/bitcoin-v${PV}.tar.gz.asc )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~mips ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="
	>=dev-libs/boost-1.52.0:=[threads(+)]
	dev-libs/libevent:=
	>=dev-libs/univalue-1.0.4:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	verify-sig? ( app-crypt/openpgp-keys-kristapsk )
"

DOCS=(
	doc/release-notes.md
)

VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/KristapsKaupe.asc

S="${WORKDIR}/bitcoin-${PV}"

pkg_pretend() {
	elog "You are building ${PN} from Bitcoin Core."
	elog "For more information, see:"
	elog "https://bitcoincore.org/en/releases/${PV}/"
}

src_prepare() {
	eapply_user

	echo '#!/bin/true' >share/genbuild.sh || die
	mkdir -p src/obj || die
	echo "#define BUILD_SUFFIX gentoo${PVR#${PV}}" >src/obj/build.h || die

	eautoreconf
	rm -r src/leveldb src/secp256k1 || die
}

src_configure() {
	local my_econf=(
		--disable-asm
		--without-qtdbus
		--without-qrencode
		--without-miniupnpc
		--disable-tests
		--disable-wallet
		--disable-zmq
		--enable-util-cli
		--disable-util-tx
		--disable-util-wallet
		--disable-bench
		--without-libs
		--without-daemon
		--without-gui
		--disable-fuzz
		--disable-ccache
		--disable-static
		--with-system-univalue
	)
	econf "${my_econf[@]}"
}

src_install() {
	default

	newbashcomp contrib/bitcoin-cli.bash-completion ${PN}
}
