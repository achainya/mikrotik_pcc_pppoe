# feb/17/2023 07:48:19 by RouterOS 7.7
# software id = G7FH-PUKJ
#
# model = RB3011UiAS
# serial number = B88E0BA02278
/interface bridge
add comment="Loopback interface for emergency routing" name=bridge-loopback
add name=bridge1
/interface ethernet
set [ find default-name=sfp1 ] disabled=yes
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-out1 user=speedy
add disabled=no interface=ether2 name=pppoe-out2 user=speedy
add disabled=no interface=ether3 name=pppoe-out3 user=speedy
add disabled=no interface=ether4 name=pppoe-out4 user=speedy
add disabled=no interface=ether5 name=pppoe-out5 user=speedy
/interface list
add comment="For Internet" name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/routing table
add disabled=no fib name=to_ISP1
add disabled=no fib name=to_ISP2
add disabled=no fib name=to_ISP3
add disabled=no fib name=to_ISP4
add disabled=no fib name=to_ISP5
/zerotier
set zt1 comment="ZeroTier Central controller - https://my.zerotier.com/" \
    identity="3f6e614493:0:d74111960d8628fe8a878c4bd1b465da39e1e42c9c6acb9735b\
    1fd69aceba164aa36b35314e1d1edef140321095903ba16db12a41e233ab202296ac7f2346\
    6cb:f4ffb698e39ccfe36791d1ce8bdf64fb1326599f1496cd01a563923ea10855ba7c67a1\
    895c917f1ccb48e1fb70d85159e684c9634b8f925e8f743062a81a5cb4" name=zt1 \
    port=9993
/zerotier interface
add allow-default=no allow-global=no allow-managed=yes disabled=no instance=\
    zt1 name=zerotier1 network=1d71939404d61032
/interface bridge port
add bridge=bridge1 interface=ether6
add bridge=bridge1 interface=ether7
add bridge=bridge1 interface=ether8
add bridge=bridge1 interface=ether9
add bridge=bridge1 interface=ether10
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=WAN
add interface=ether4 list=WAN
add interface=ether5 list=WAN
add interface=pppoe-out1 list=WAN
add interface=pppoe-out2 list=WAN
add interface=pppoe-out3 list=WAN
add interface=pppoe-out4 list=WAN
add interface=pppoe-out5 list=WAN
add interface=bridge1 list=LAN
/ip address
add address=192.168.100.1/24 interface=bridge1 network=192.168.100.0
/ip dns
set servers=8.8.8.8,8.8.4.4
/ip firewall address-list
add address=10.0.0.0/8 list=RFC1918
add address=172.16.0.0/12 list=RFC1918
add address=192.168.0.0/16 list=RFC1918
/ip firewall filter
add action=accept chain=forward in-interface=zerotier1
add action=accept chain=input in-interface=zerotier1
/ip firewall mangle
add action=accept chain=prerouting comment="No balancear Trafico Privado" \
    dst-address-list=RFC1918 src-address-list=RFC1918
# pppoe-out1 not ready
add action=mark-connection chain=prerouting comment=\
    "Marcado de Conexiones Originadas en Internet" connection-mark=no-mark \
    in-interface=pppoe-out1 new-connection-mark=ISP1_conn passthrough=yes
# pppoe-out2 not ready
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out2 new-connection-mark=ISP2_conn passthrough=yes
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out3 new-connection-mark=ISP3_conn passthrough=yes
# pppoe-out4 not ready
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out4 new-connection-mark=ISP4_conn passthrough=yes
# pppoe-out5 not ready
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out5 new-connection-mark=ISP5_conn passthrough=yes
add action=mark-connection chain=prerouting comment=\
    "Marcado de conexiones - entrando via LAN" connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP1_conn passthrough=yes per-connection-classifier=both-addresses:5/0
add action=mark-routing chain=prerouting connection-mark=ISP1_conn \
    in-interface-list=LAN new-routing-mark=to_ISP1 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP2_conn passthrough=yes per-connection-classifier=both-addresses:5/1
add action=mark-routing chain=prerouting connection-mark=ISP2_conn \
    in-interface-list=LAN new-routing-mark=to_ISP2 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP3_conn passthrough=yes per-connection-classifier=both-addresses:5/2
add action=mark-routing chain=prerouting connection-mark=ISP3_conn \
    in-interface-list=LAN new-routing-mark=to_ISP3 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP4_conn passthrough=yes per-connection-classifier=both-addresses:5/3
add action=mark-routing chain=prerouting connection-mark=ISP4_conn \
    in-interface-list=LAN new-routing-mark=to_ISP4 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP5_conn passthrough=yes per-connection-classifier=both-addresses:5/4
add action=mark-routing chain=prerouting connection-mark=ISP5_conn \
    in-interface-list=LAN new-routing-mark=to_ISP5 passthrough=no
add action=mark-routing chain=output connection-mark=ISP1_conn \
    new-routing-mark=to_ISP1 passthrough=no
add action=mark-routing chain=output connection-mark=ISP2_conn \
    new-routing-mark=to_ISP2 passthrough=no
add action=mark-routing chain=output connection-mark=ISP3_conn \
    new-routing-mark=to_ISP3 passthrough=no
add action=mark-routing chain=output connection-mark=ISP4_conn \
    new-routing-mark=to_ISP4 passthrough=no
add action=mark-routing chain=output connection-mark=ISP5_conn \
    new-routing-mark=to_ISP5 passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN src-address-list=\
    RFC1918
/ip route
add comment="Emergency route" distance=254 gateway=bridge-loopback
add comment="Unmarket via PPPoE-01" distance=1 gateway=pppoe-out1
add comment="Unmarket via PPPoE-02" distance=2 gateway=pppoe-out2
add comment="Unmarket via PPPoE-03" distance=3 gateway=pppoe-out3
add comment="Unmarket via PPPoE-04" distance=4 gateway=pppoe-out4
add comment="Unmarket via PPPoE-05" distance=5 gateway=pppoe-out5
add comment="Marked via PPPoE-01 Main" distance=1 gateway=pppoe-out1 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-1" distance=2 gateway=pppoe-out2 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-2" distance=3 gateway=pppoe-out3 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-3" distance=4 gateway=pppoe-out4 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-4" distance=5 gateway=pppoe-out5 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-02 Main" distance=1 gateway=pppoe-out2 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-2" distance=3 gateway=pppoe-out3 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-3" distance=4 gateway=pppoe-out4 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-4" distance=5 gateway=pppoe-out5 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-03 Main" distance=1 gateway=pppoe-out3 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-2" distance=3 gateway=pppoe-out2 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-3" distance=4 gateway=pppoe-out4 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-4" distance=5 gateway=pppoe-out5 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-04 Main" distance=1 gateway=pppoe-out4 \
    routing-table=to_ISP4
add comment="Marked via PPPoE-04 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP4
add comment="Marked via PPPoE-04 Backup-2" distance=3 gateway=pppoe-out2 \
    routing-table=to_ISP4
add comment="Marked via PPPoE-04 Backup-3" distance=4 gateway=pppoe-out3 \
    routing-table=to_ISP4
add comment="Marked via PPPoE-04 Backup-4" distance=5 gateway=pppoe-out5 \
    routing-table=to_ISP4
add comment="Marked via PPPoE-05 Main" distance=1 gateway=pppoe-out5 \
    routing-table=to_ISP5
add comment="Marked via PPPoE-05 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP5
add comment="Marked via PPPoE-05 Backup-2" distance=3 gateway=pppoe-out2 \
    routing-table=to_ISP5
add comment="Marked via PPPoE-05 Backup-3" distance=4 gateway=pppoe-out3 \
    routing-table=to_ISP5
add comment="Marked via PPPoE-05 Backup-4" distance=5 gateway=pppoe-out4 \
    routing-table=to_ISP5
/ip service
set telnet disabled=yes
set ftp disabled=yes
/system clock
set time-zone-name=America/Lima
/system identity
set name=RB3011-02
/tool romon
set enabled=yes
