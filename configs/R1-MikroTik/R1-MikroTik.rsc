# 2026-11-17 09:40:46 by RouterOS 7.24.5
# system id = WEXaB0Bw8BI
#
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no name=ether1-WAN
/interface ethernet set [ find default-name=ether2 ] disable-running-check=no name=ether2-LAN
/ip address add address=10.0.2.15/24 comment="WAN - VirtualBox NAT" interface=ether1-WAN network=10.0.2.0
/ip address add address=192.168.30.1/24 comment="LAN G3" interface=ether2-LAN network=192.168.30.0
/ip dns set servers=172.16.222.1
/ip firewall nat add action=masquerade chain=srcnat comment="NAT LAN -> WAN" out-interface=ether1-WAN
/ip route add comment="Default via NAT VirtualBox" dst-address=0.0.0.0/0 gateway=10.0.2.2
/system clock set time-zone-name=Europe/Madrid
/system identity set name=R1-MikroTik
