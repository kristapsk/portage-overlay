# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"
inherit autotools bash-completion-r1 db-use systemd verify-sig

KRISTAPSK_PV="${PV}.20210502"

DESCRIPTION="Original Bitcoin crypto-currency wallet for automated services"
HOMEPAGE="https://bitcoincore.org/"
SRC_URI="
	https://github.com/bitcoin/bitcoin/archive/v${PV}.tar.gz -> bitcoin-v${PV}.tar.gz
	https://github.com/kristapsk/bitcoin-core-patches/archive/refs/tags/v${KRISTAPSK_PV}.tar.gz -> bitcoin-kristapsk-patches-${KRISTAPSK_PV}.tar.gz
	verify-sig? (
		https://github.com/kristapsk/bitcoin-core-patches/releases/download/v${KRISTAPSK_PV}/bitcoin-v${PV}.tar.gz.asc
		https://github.com/kristapsk/bitcoin-core-patches/releases/download/v${KRISTAPSK_PV}/bitcoin-kristapsk-patches-${KRISTAPSK_PV}.tar.gz.asc
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~mips ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="+asm examples +kristapsk-patches system-leveldb test upnp +wallet zeromq"
RESTRICT="!test? ( test )"

DEPEND="
	acct-group/bitcoin
	acct-user/bitcoin
	>=dev-libs/boost-1.52.0:=[threads(+)]
	dev-libs/libevent:=
	>=dev-libs/univalue-1.0.4:=
	system-leveldb? ( virtual/bitcoin-leveldb )
	upnp? ( >=net-libs/miniupnpc-1.9.20150916:= )
	wallet? ( sys-libs/db:$(db_ver_to_slot "${DB_VER}")=[cxx] )
	zeromq? ( net-libs/zeromq:= )
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	verify-sig? ( app-crypt/openpgp-keys-kristapsk )
"

DOCS=(
	doc/bips.md
	doc/bitcoin-conf.md
	doc/descriptors.md
	doc/files.md
	doc/JSON-RPC-interface.md
	doc/psbt.md
	doc/reduce-traffic.md
	doc/release-notes.md
	doc/REST-interface.md
	doc/tor.md
)

VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/KristapsKaupe.asc

S="${WORKDIR}/bitcoin-${PV}"

pkg_pretend() {
	elog "You are building ${PN} from Bitcoin Core."
	elog "For more information, see:"
	elog "https://bitcoincore.org/en/releases/${PV}/"
	if use kristapsk-patches; then
		elog "Additional patches on top are applied, see:"
		elog "https://github.com/kristapsk/bitcoin-core-patches/tree/v${PV}"
	fi
	elog "Replace By Fee policy is now always enabled by default: Your node will"
	elog "preferentially mine and relay transactions paying the highest fee, regardless"
	elog "of receive order. To disable RBF, set mempoolreplacement=never in bitcoin.conf"
}

src_prepare() {
	sed -i 's/^\(complete -F _bitcoind bitcoind\) bitcoin-qt$/\1/' contrib/${PN}.bash-completion || die

	if use kristapsk-patches; then
		for f in ${WORKDIR}/bitcoin-core-patches-${KRISTAPSK_PV}/*.patch; do
			eapply "$f"
		done
	fi

	default

	echo '#!/bin/true' >share/genbuild.sh || die
	mkdir -p src/obj || die
	echo "#define BUILD_SUFFIX gentoo${PVR#${PV}}" >src/obj/build.h || die

	eautoreconf
	if use system-leveldb; then
		rm -r src/leveldb || die
	fi
}

src_configure() {
	local my_econf=(
		$(use_enable asm)
		--without-qtdbus
		--without-qrencode
		$(use_with upnp miniupnpc)
		$(use_enable upnp upnp-default)
		$(use_enable test tests)
		$(use_enable wallet)
		$(use_enable zeromq zmq)
		--with-daemon
		--disable-util-cli
		--disable-util-tx
		--disable-util-wallet
		--disable-bench
		--without-libs
		--without-gui
		--disable-fuzz
		--disable-ccache
		--disable-static
		$(use_with system-leveldb)
		--with-system-univalue
	)
	econf "${my_econf[@]}"
}

src_install() {
	default

	rm -f "${ED}/usr/bin/test_bitcoin" || die

	insinto /etc/bitcoin
	newins "${FILESDIR}/bitcoin.conf" bitcoin.conf
	fowners bitcoin:bitcoin /etc/bitcoin/bitcoin.conf
	fperms 600 /etc/bitcoin/bitcoin.conf

	newconfd "contrib/init/bitcoind.openrcconf" ${PN}
	newinitd "contrib/init/bitcoind.openrc" ${PN}
	systemd_newunit "contrib/init/bitcoind.service" "bitcoind.service"

	keepdir /var/lib/bitcoin/.bitcoin
	fperms 700 /var/lib/bitcoin
	fowners bitcoin:bitcoin /var/lib/bitcoin/
	fowners bitcoin:bitcoin /var/lib/bitcoin/.bitcoin
	dosym ../../../../etc/bitcoin/bitcoin.conf /var/lib/bitcoin/.bitcoin/bitcoin.conf

	doman "${FILESDIR}/bitcoin.conf.5"

	use zeromq && dodoc doc/zmq.md

	newbashcomp contrib/${PN}.bash-completion ${PN}

	if use examples; then
		docinto examples
		dodoc -r contrib/{linearize,qos}
		use zeromq && dodoc -r contrib/zmq
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/bitcoind.logrotate-r1" bitcoind
}

pkg_postinst() {
	elog "To have ${PN} automatically use Tor when it's running, be sure your"
	elog "'torrc' config file has 'ControlPort' and 'CookieAuthentication' setup"
	elog "correctly, and:"
	elog "- Using an init script: add the 'bitcoin' user to the 'tor' user group."
	elog "- Running bitcoind directly: add that user to the 'tor' user group."
}
