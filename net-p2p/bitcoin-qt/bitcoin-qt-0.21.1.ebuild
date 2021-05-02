# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"
inherit autotools bash-completion-r1 db-use desktop xdg-utils

KRISTAPSK_PV="${PV}.20210502"

DESCRIPTION="An end-user Qt GUI for the Bitcoin crypto-currency"
HOMEPAGE="https://bitcoincore.org/"
SRC_URI="
	https://github.com/bitcoin/bitcoin/archive/v${PV}.tar.gz -> bitcoin-v${PV}.tar.gz
	https://github.com/kristapsk/bitcoin-core-patches/archive/refs/tags/v${KRISTAPSK_PV}.tar.gz -> bitcoin-kristapsk-patches-${KRISTAPSK_PV}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"

IUSE="+asm dbus kde +kristapsk-patches +qrcode system-leveldb test upnp +wallet zeromq"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/boost-1.52.0:=[threads(+)]
	>=dev-libs/univalue-1.0.4:=
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	system-leveldb? ( virtual/bitcoin-leveldb )
	dbus? ( dev-qt/qtdbus:5 )
	dev-libs/libevent:=
	qrcode? (
		media-gfx/qrencode:=
	)
	upnp? ( >=net-libs/miniupnpc-1.9.20150916:= )
	wallet? ( sys-libs/db:$(db_ver_to_slot "${DB_VER}")=[cxx] )
	zeromq? ( net-libs/zeromq:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	dev-qt/linguist-tools:5
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

S="${WORKDIR}/bitcoin-${PV}"

pkg_pretend() {
	elog "You are building ${PN} from Bitcoin Core."
	elog "For more information, see:"
	elog "https://bitcoincore.org/en/2020/08/01/release-${PV}/"
	elog "Replace By Fee policy is now always enabled by default: Your node will"
	elog "preferentially mine and relay transactions paying the highest fee, regardless"
	elog "of receive order. To disable RBF, set mempoolreplacement=never in bitcoin.conf"
}

src_prepare() {
	sed -i 's/^\(complete -F _bitcoind \)bitcoind \(bitcoin-qt\)$/\1\2/' contrib/bitcoind.bash-completion || die

	# Save the generic icon for later
	cp src/qt/res/src/bitcoin.svg bitcoin128.svg || die

	if use kristapsk-patches; then
		for f in ${WORKDIR}/bitcoin-core-patches-${KRISTAPSK_PV}/*.patch; do
			eapply "$f"
		done
	fi

	eapply_user

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
		$(use_with dbus qtdbus)
		$(use_with qrcode qrencode)
		$(use_with upnp miniupnpc)
		$(use_enable upnp upnp-default)
		$(use_enable test tests)
		$(use_enable wallet)
		$(use_enable zeromq zmq)
		--with-gui=qt5
		--disable-util-cli
		--disable-util-tx
		--disable-util-wallet
		--disable-bench
		--without-libs
		--without-daemon
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

	insinto /usr/share/icons/hicolor/scalable/apps/
	doins bitcoin128.svg

	cp "${FILESDIR}/org.bitcoin.bitcoin-qt.desktop" "${T}" || die
	domenu "${T}/org.bitcoin.bitcoin-qt.desktop"
	if use test; then
		for testnet in regtest testnet signet; do
			cat "${FILESDIR}/org.bitcoin.bitcoin-qt.desktop" | \
				sed "s/Name=Bitcoin Core/Name=Bitcoin Core ($testnet)/" | \
				sed "s/Exec=bitcoin-qt /Exec=bitcoin-qt -$testnet/" > \
					"${T}/org.bitcoin.bitcoin-qt-$testnet.desktop"
			domenu "${T}/org.bitcoin.bitcoin-qt-$testnet.desktop"
		done
	fi

	use zeromq && dodoc doc/zmq.md

	newbashcomp contrib/bitcoind.bash-completion ${PN}

	if use kde; then
		insinto /usr/share/kservices5
		doins "${FILESDIR}/bitcoin-qt.protocol"
		dosym "../../kservices5/bitcoin-qt.protocol" "/usr/share/kde4/services/bitcoin-qt.protocol"
	fi
}

update_caches() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	update_caches

	elog "To have ${PN} automatically use Tor when it's running, be sure your"
	elog "'torrc' config file has 'ControlPort' and 'CookieAuthentication' setup"
	elog "correctly, and add your user to the 'tor' user group."
}

pkg_postrm() {
	update_caches
}
