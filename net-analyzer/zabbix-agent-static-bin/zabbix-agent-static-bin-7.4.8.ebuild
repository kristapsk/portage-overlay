# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="ZABBIX is software for monitoring of your applications, network and servers"
HOMEPAGE="https://www.zabbix.com/"
SRC_URI="https://cdn.zabbix.com/zabbix/binaries/stable/$(ver_cut 1-2)/${PV}/zabbix_agent-${PV}-linux-3.0-amd64-static.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	acct-group/zabbix
	acct-user/zabbix"
BDEPEND=""

src_install() {
	insinto /etc/zabbix
	doins "${S}"/conf/zabbix_agentd.conf
	fperms 0640 /etc/zabbix/zabbix_agentd.conf
	fowners root:zabbix /etc/zabbix/zabbix_agentd.conf

	newinitd "${FILESDIR}"/zabbix-agentd.init zabbix-agentd

	dosbin "${S}"/sbin/zabbix_agentd
	dobin \
		"${S}"/bin/zabbix_sender \
		"${S}"/bin/zabbix_get
}
