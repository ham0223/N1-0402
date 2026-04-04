#!/bin/bash
set -e 

# 1. 基础环境设置 (IP: 192.168.123.2 | 主机名: OpenWrt)
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
sed -i 's/LEDE/OpenWrt/g' package/base-files/files/bin/config_generate

# 2. 彻底清理 feeds 冲突 (防止 PassWall, Nikki, TurboACC 等重复报错)
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls,zerotier,socat}
rm -rf feeds/luci/applications/luci-app-{passwall*,mosdns,lucky,nikki,openclash,zerotier,socat,turboacc,dockerman,samba4,vsftpd,softethervpn}

# 3. 插件仓库拉取 (含官方 PassWall & 额外增强插件)
# PassWall 官方最新版
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/Openwrt-Passwall/openwrt-passwall2 package/passwall2

# 常用核心插件 (Nikki, OpenClash, Lucky, MosDNS)
git clone https://github.com/nikkinikki-org/OpenWrt-nikki --depth=1 package/nikki
git clone https://github.com/vernesong/OpenClash --depth=1 package/openclash
git clone https://github.com/gdy666/luci-app-lucky.git --depth=1 package/lucky
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --depth=1 package/mosdns
git clone https://github.com/sbwml/luci-app-openlist2 --depth=1 package/openlist2

# 系统与加速插件
git clone https://github.com/ophub/luci-app-amlogic --depth=1 package/amlogic
# 注：Docker, Samba4, ZeroTier, Socat, Turboacc 等通常在常用 feeds 中已包含，直接在 config 开启即可


# 4. 修复系统库依赖 (防止 armsr 架构下的编译中断)
sed -i 's/REENTRANT -D_GNU_SOURCE/LARGEFILE64_SOURCE/g' feeds/packages/lang/perl/Makefile

# 5. 修正俩处错误的翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm