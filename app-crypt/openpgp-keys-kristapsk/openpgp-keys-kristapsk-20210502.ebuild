# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OpenGPG keys used by Kristaps Kaupe"
HOMEPAGE="https://github.com/kristapsk"
SRC_URI="https://raw.githubusercontent.com/JoinMarket-Org/joinmarket-clientserver/709db9ea3b7a18a070e8b76943d57bdfad46df60/pubkeys/KristapsKaupe.asc"
S="${WORKDIR}"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"

src_install() {
	local files=( ${A} )

	insinto /usr/share/openpgp-keys
	newins - KristapsKaupe.asc < <(cat "${files[@]/#/${DISTDIR}/}" || die)
}
