# feb/17/2023 07:47:02 by RouterOS 7.7
# software id = 8KPS-2VJ6
#
# model = RB3011UiAS
# serial number = 8EEE09FBD4A8
/interface bridge
add comment="Loopback interface for emergency routing" name=bridge-loopback
add name=bridge1
/interface ethernet
set [ find default-name=sfp1 ] disabled=yes
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-out1 user=speedy
add disabled=no interface=ether2 name=pppoe-out2 user=speedy
add disabled=no interface=ether3 name=pppoe-out3 user=speedy
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/routing table
add disabled=no fib name=to_ISP1
add disabled=no fib name=to_ISP2
add disabled=no fib name=to_ISP3
/zerotier
set zt1 comment="ZeroTier Central controller - https://my.zerotier.com/" \
    identity="a71d79353b:0:6dbc91c03eb9aad85ce037ac7112c861abfc16a720dbefba18f\
    e1a6d8537e064d4b2a28af243d073cbbd209f4aa139b8c2f91a7af6a7c7fad56c3c132127a\
    6ce:214bfac9c0f7fc1d2baba7e87882fb3b9017eeb049cbf03545779802d1a1ce335f9b87\
    a325faac06e242ba5451777fca27e1e5c42d39d91b46c617d49d526110" name=zt1 \
    port=9993
/zerotier interface
add allow-default=no allow-global=no allow-managed=yes disabled=no instance=\
    zt1 name=zerotier1 network=1d71939404d61032
/interface bridge port
add bridge=bridge1 interface=ether4
add bridge=bridge1 interface=ether5
add bridge=bridge1 interface=ether6
add bridge=bridge1 interface=ether7
add bridge=bridge1 interface=ether8
add bridge=bridge1 interface=ether9
add bridge=bridge1 interface=ether10
/interface list member
add interface=pppoe-out1 list=WAN
add interface=pppoe-out2 list=WAN
add interface=pppoe-out3 list=WAN
add interface=bridge1 list=LAN
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=WAN
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
add action=mark-connection chain=prerouting comment=\
    "Marcado de Conexiones Originadas en Internet" connection-mark=no-mark \
    in-interface=pppoe-out1 new-connection-mark=ISP1_conn passthrough=yes
# pppoe-out2 not ready
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out2 new-connection-mark=ISP2_conn passthrough=yes
# pppoe-out3 not ready
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=pppoe-out3 new-connection-mark=ISP3_conn passthrough=yes
add action=mark-connection chain=prerouting comment=\
    "Marcado de conexiones - entrando via LAN" connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP1_conn passthrough=yes per-connection-classifier=both-addresses:3/0
add action=mark-routing chain=prerouting connection-mark=ISP1_conn \
    in-interface-list=LAN new-routing-mark=to_ISP1 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP2_conn passthrough=yes per-connection-classifier=both-addresses:3/1
add action=mark-routing chain=prerouting connection-mark=ISP2_conn \
    in-interface-list=LAN new-routing-mark=to_ISP2 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-type=!local in-interface-list=LAN new-connection-mark=\
    ISP3_conn passthrough=yes per-connection-classifier=both-addresses:3/2
add action=mark-routing chain=prerouting connection-mark=ISP3_conn \
    in-interface-list=LAN new-routing-mark=to_ISP3 passthrough=no
add action=mark-routing chain=output connection-mark=ISP1_conn \
    new-routing-mark=to_ISP1 passthrough=no
add action=mark-routing chain=output connection-mark=ISP2_conn \
    new-routing-mark=to_ISP2 passthrough=no
add action=mark-routing chain=output connection-mark=ISP3_conn \
    new-routing-mark=to_ISP3 passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN src-address-list=\
    RFC1918
/ip route
add comment="Emergency route" distance=254 gateway=bridge-loopback
add comment="Unmarket via PPPoE-01" distance=1 gateway=pppoe-out1
add comment="Unmarket via PPPoE-02" distance=2 gateway=pppoe-out2
add comment="Unmarket via PPPoE-03" distance=3 gateway=pppoe-out3
add comment="Marked via PPPoE-01 Main" distance=1 gateway=pppoe-out1 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-1" distance=2 gateway=pppoe-out2 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-01 Backup-2" distance=2 gateway=pppoe-out3 \
    routing-table=to_ISP1
add comment="Marked via PPPoE-02 Main" distance=1 gateway=pppoe-out2 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-02 Backup-2" distance=3 gateway=pppoe-out3 \
    routing-table=to_ISP2
add comment="Marked via PPPoE-03 Main" distance=1 gateway=pppoe-out3 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-1" distance=2 gateway=pppoe-out1 \
    routing-table=to_ISP3
add comment="Marked via PPPoE-03 Backup-2" distance=3 gateway=pppoe-out2 \
    routing-table=to_ISP3
/ip service
set telnet disabled=yes
set ftp disabled=yes
/system clock
set time-zone-name=America/Lima
/system identity
set name=RB3011-01
/tool romon
set enabled=yes
