# 2026-11-22 00:00:30 by RouterOS 7.25.1
# system id = (oculto)
#
/ip ssh
set host-key-type=rsa known-hosts-validation=no
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-WAN
set [ find default-name=ether2 ] disable-running-check=no name=ether2-LAN
/ip address
add address=10.0.2.15/24 comment="WAN - VirtualBox NAT" interface=ether1-WAN \
    network=10.0.2.0
add address=192.168.30.1/24 comment="LAN G3" interface=ether2-LAN network=\
    192.168.30.0
/ip dns
set servers=172.16.222.1
/ip firewall filter
add action=drop chain=forward comment="Tasca 5: DNS externo bloqueado (TCP)" \
    dst-address=!172.16.222.1 dst-port=53 in-interface=ether2-LAN log=yes \
    log-prefix=R1-BLOQ-DNS-EXT protocol=tcp
add action=drop chain=forward comment="Tasca 5: DNS externo bloqueado (UDP)" \
    dst-address=!172.16.222.1 dst-port=53 in-interface=ether2-LAN log=yes \
    log-prefix=R1-BLOQ-DNS-EXT protocol=udp
add action=accept chain=forward comment=\
    "Tasca 5: HTTP permitido y registrado" connection-state=new dst-port=80 \
    in-interface=ether2-LAN log=yes log-prefix=R1-PERMITE-HTTP out-interface=\
    ether1-WAN protocol=tcp src-address=192.168.30.0/24
/ip firewall nat
add action=masquerade chain=srcnat comment="NAT LAN -> WAN" out-interface=\
    ether1-WAN
/ip route
add comment="Default via NAT VirtualBox" dst-address=0.0.0.0/0 gateway=\
    10.0.2.2
/system clock
set time-zone-name=Europe/Madrid
/system identity
set name=R1-MikroTik
/system scheduler
add !days interval=1d name=copia-nas on-event=copia-nas policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-11-21 start-time=02:00:00
/system script
add dont-require-permissions=no name=copia-nas owner=admin policy=\
    ftp,read,write,policy,test,sensitive source=":local f (\"R1-\" . [/system \
    clock get date]); /system backup save name=\$f dont-encrypt=yes; /export s\
    how-sensitive file=\$f; :delay 3s; :foreach e in={\".backup\";\".rsc\"} do\
    ={ /tool fetch upload=yes mode=sftp address=192.168.30.20 user=copias pass\
    word=******** src-path=(\$f . \$e) dst-path=(\"/mnt/copias/configuraciones\
    /r1-mikrotik/\" . \$f . \$e) }; /file remove [find where name~\"^R1-\"]; :\
    log info (\"copia-nas: \" . \$f . \" subida al NAS\")"
/user ssh-keys
add info=proyecto-sox-fhw key="ssh-ed25519 (clave pública oculta)" user=admin
