#!/bin/bash
set -e  # 任何命令失败立即退出，防止静默跳过错误

# 修改IP及主机名
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
sed -i 's/LEDE/OpenWrt/g' package/base-files/files/bin/config_generate

# 彻底清理 feeds 自带的冲突项
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2
rm -rf feeds/luci/applications/luci-app-mosdns feeds/packages/net/mosdns
rm -rf feeds/packages/net/openlist
rm -rf feeds/luci/applications/luci-app-openlist
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/luci/applications/luci-app-nikki
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openlist2

rm -rf feeds/luci/luci-app-mjpg-streamer
rm -rf feeds/packages/onionshare-cli
rm -rf package/feeds/luci/luci-app-mjpg-streamer
rm -rf package/feeds/packages/onionshare-cli
sed -i '/mjpg-streamer/d' .config 2>/dev/null || true
sed -i '/onionshare/d' .config 2>/dev/null || true

# 删除 telephony 中有问题的包
rm -rf feeds/telephony/freeswitch
rm -rf feeds/telephony/spandsp3
rm -rf package/feeds/telephony/freeswitch
rm -rf package/feeds/telephony/spandsp3

# 消除 WARNING：删除依赖已删除的 freeswitch/spandsp3 的下游包
rm -rf feeds/telephony/freeswitch-mod-bcg729
rm -rf feeds/telephony/freetdm
rm -rf feeds/telephony/rtpengine
rm -rf feeds/telephony/baresip
rm -rf package/feeds/telephony/freeswitch-mod-bcg729
rm -rf package/feeds/telephony/freetdm
rm -rf package/feeds/telephony/rtpengine
rm -rf package/feeds/telephony/baresip

# 消除 WARNING：删除引发 nikki↔firewall4 循环依赖的 luci-app-fchomo
find feeds/ package/feeds/ -type d -name "luci-app-fchomo" 2>/dev/null | xargs rm -rf
sed -i '/luci-app-fchomo/d' .config 2>/dev/null || true

rm -rf feeds/kenzo/luci-theme-alpha
rm -rf package/feeds/kenzo/luci-theme-alpha


# 克隆 Passwall 2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall-packages
rm -rf package/passwall-packages/shadowsocksr-libev
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall.git package/passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git package/passwall2


# 其他插件
git clone https://github.com/ophub/luci-app-amlogic --depth=1 package/amlogic
git clone https://github.com/gdy666/luci-app-lucky.git --depth=1 package/lucky
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --depth=1 package/mosdns
git clone https://github.com/sbwml/luci-app-openlist2 --depth=1 package/openlist2
git clone https://github.com/nikkinikki-org/OpenWrt-nikki --depth=1 package/nikki
git clone https://github.com/vernesong/OpenClash --depth=1 package/openclash

# 临时修复acpid,aliyundrive-webdav,xfsprogs,perl-html-parser,v2dat 导致的编译失败问题
#sed -i 's#flto#flto -D_LARGEFILE64_SOURCE#g' feeds/packages/utils/acpid/Makefile
#sed -i 's/stripped/release/g' feeds/packages/multimedia/aliyundrive-webdav/Makefile
#sed -i 's#SYNC#SYNC -D_LARGEFILE64_SOURCE#g' feeds/packages/utils/xfsprogs/Makefile
sed -i 's/REENTRANT -D_GNU_SOURCE/LARGEFILE64_SOURCE/g' feeds/packages/lang/perl/perlmod.mk
sed -i 's#GO_PKG_TARGET_VARS.*# #g' feeds/packages/utils/v2dat/Makefile

# 修复v2ray-plugin编译失败
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 修正俩处错误的翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
