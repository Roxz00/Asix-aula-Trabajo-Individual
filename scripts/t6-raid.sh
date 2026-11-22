#!/bin/bash
# t6-raid.sh · Pruebas de RAID de la Tasca 6 en deb-produccion (Debian 13 + mdadm). Se ejecuta con sudo.
# Discos virtuales de 256 MB (VirtualBox, puertos SATA 1-9) con datos ficticios:
#   sdb sdc -> md0 (RAID 0) · sdd sde -> md1 (RAID 1) · sdf sdg sdh -> md5 (RAID 5)
#   sdi     -> disco de repuesto (y medida de un disco solo)
#   sdj + LUN iSCSI del NAS -> md10 (RAID 1 entre dos equipos, Apte+)
# Uso: t6-raid.sh crear | estado md0 md1… | medir | raid0-roto | raid0-rehacer DISCO | raid1-sustituir | raid5-fallo | raid5-reconstruir
#      t6-raid.sh espejo-crear | espejo-estado | espejo-escribir | espejo-readd | persistir
# Los fallos "de hardware" (quitar un disco o el cable del NAS) se hacen desde el anfitrión con VBoxManage.
set -u
IQN_NAS="iqn.2005-10.org.freenas.ctl:espejo-deb"
IQN_CLI="iqn.2026-11.local.g3:deb-produccion"
NAS=192.168.30.20
t()  { echo; echo "== $(date +%H:%M:%S) · $*"; }
seg() { date +%s.%N; }
dur() { awk -v a="$1" -v b="$(seg)" 'BEGIN{printf "%.1f s", b-a}'; }
remoto() { readlink -f /dev/disk/by-path/*"$IQN_NAS"-lun-0 2>/dev/null; }

datos() {   # datos ficticios + sumas SHA256 para comprobar después que no se han perdido
    local dir=$1
    python3 - "$dir" <<'EOF'
import random, sys
random.seed(6)
nombres = ["Laia", "Marc", "Nerea", "Pau", "Irene", "Joan", "Aina", "Hugo"]
with open(sys.argv[1] + "/clientes-ficticios.csv", "w") as f:
    f.write("id;nombre;ciudad;importe\n")
    for i in range(1, 20001):
        f.write(f"{i};{random.choice(nombres)};Ciudad-{random.randint(1, 50)};{random.randint(10, 9999)}\n")
EOF
    head -c 60M /dev/urandom > "$dir/imagen-ficticia.bin"
    ( cd "$dir" && sha256sum clientes-ficticios.csv imagen-ficticia.bin > SHA256SUMS )
    sync
}
comprobar() { ( cd "$1" && sha256sum -c SHA256SUMS 2>&1 ) ; }

case "${1:-}" in
crear)
    t "Discos disponibles"; lsblk -d -o NAME,SIZE,TYPE /dev/sd[b-j]
    for d in /dev/sd[b-j]; do wipefs -aq "$d"; done
    t "RAID 0 (md0) con sdb + sdc"
    mdadm --create /dev/md0 --run --level=0 --raid-devices=2 /dev/sdb /dev/sdc
    t "RAID 1 (md1) con sdd + sde"
    mdadm --create /dev/md1 --run --level=1 --metadata=1.2 --raid-devices=2 /dev/sdd /dev/sde
    t "RAID 5 (md5) con sdf + sdg + sdh"
    mdadm --create /dev/md5 --run --level=5 --raid-devices=3 /dev/sdf /dev/sdg /dev/sdh
    a=$(seg); mdadm --wait /dev/md1 /dev/md5; echo "Sincronización inicial de md1 y md5: $(dur "$a")"
    for n in 0 1 5; do
        mkfs.ext4 -F -q -L raid$n /dev/md$n
        mkdir -p /srv/raid$n && mount /dev/md$n /srv/raid$n
        datos /srv/raid$n
    done
    t "Estado"; cat /proc/mdstat
    t "Capacidad útil (3 tipos con discos de 256 MB)"
    df -h --output=source,size,used,avail,target /srv/raid0 /srv/raid1 /srv/raid5
    ;;
estado)
    t "/proc/mdstat"; cat /proc/mdstat
    for m in "${@:2}"; do t "mdadm --detail /dev/$m"; mdadm --detail /dev/$m | grep -E 'Raid Level|Array Size|Raid Devices|State :|Active|Working|Failed|Spare|Rebuild|/dev/sd|removed|Bitmap|Consistency'; done
    ;;
medir)
    # Velocidad secuencial con E/S directa (sin caché). Los 9 discos son ficheros del mismo disco del
    # anfitrión: los números sirven para comparar entre sí, no como velocidad real de un RAID.
    t "Velocidad secuencial (100 MB, oflag/iflag=direct)"
    printf "%-22s %12s %12s\n" "Volumen" "Escritura" "Lectura"
    head -c 100M /dev/urandom > /dev/shm/aleatorio     # datos aleatorios en RAM: no se mide /dev/zero
    medir1() {  # $1 nombre, $2 fichero o dispositivo
        local w r
        w=$(LC_ALL=C dd if=/dev/shm/aleatorio of="$2" bs=1M oflag=direct conv=fdatasync 2>&1 | awk -F', ' '/copied/{print $NF}')
        echo 3 > /proc/sys/vm/drop_caches
        r=$(LC_ALL=C dd if="$2" of=/dev/null bs=1M count=100 iflag=direct 2>&1 | awk -F', ' '/copied/{print $NF}')
        printf "%-22s %12s %12s\n" "$1" "$w" "$r"
    }
    medir1 "Un disco solo (sdi)" /dev/sdi
    for n in 0 1 5; do medir1 "RAID $n (md$n)" /srv/raid$n/prueba-velocidad; rm -f /srv/raid$n/prueba-velocidad; done
    wipefs -aq /dev/sdi; rm -f /dev/shm/aleatorio
    ;;
raid0-roto)
    t "Tras quitar sdc (puerto SATA 2) del RAID 0"; cat /proc/mdstat
    t "Lectura de los datos de /srv/raid0"
    echo 3 > /proc/sys/vm/drop_caches; comprobar /srv/raid0
    t "Mensajes del núcleo"; dmesg | grep -E 'md0|md/raid0|EXT4-fs.*md0|I/O error' | tail -6
    ;;
raid0-rehacer)  # $2 = disco reconectado
    umount -l /srv/raid0; mdadm --stop /dev/md0
    t "RAID 0 perdido: se rehace vacío (los datos solo se recuperarían de una copia)"
    disco=$2    # el disco que se volvió a conectar (el núcleo le da un nombre nuevo)
    mdadm --zero-superblock /dev/sdb "$disco"; wipefs -aq /dev/sdb "$disco"
    mdadm --create /dev/md0 --run --level=0 --raid-devices=2 /dev/sdb "$disco"
    mkfs.ext4 -F -q -L raid0 /dev/md0 && mount /dev/md0 /srv/raid0 && ls /srv/raid0
    ;;
raid1-sustituir)
    t "RAID 1 tras quitar sde (puerto SATA 4) en caliente"
    echo "escritura con un disco menos" > /srv/raid1/escrito-degradado.txt; sync
    cat /proc/mdstat | sed -n '/md1/,/^$/p'
    mdadm --detail /dev/md1 | grep -E 'State :|Active|Working|Failed|/dev/sd|removed'
    t "Los datos siguen ahí"; echo 3 > /proc/sys/vm/drop_caches; comprobar /srv/raid1; cat /srv/raid1/escrito-degradado.txt
    t "Sustitución por el disco nuevo sdi"
    mdadm /dev/md1 --remove detached 2>/dev/null; mdadm /dev/md1 --add /dev/sdi
    a=$(seg); sleep 1; mdadm --wait /dev/md1; echo "Reconstrucción de md1 (256 MB): $(dur "$a")"
    mdadm --detail /dev/md1 | grep -E 'State :|Active|Working|/dev/sd'
    ;;
raid5-fallo)
    t "RAID 5: se marca sdg como averiado y se saca"
    mdadm /dev/md5 --fail /dev/sdg --remove /dev/sdg
    mdadm --detail /dev/md5 | grep -E 'State :|Active|Working|Failed|/dev/sd|removed'
    t "Los datos se leen calculando la paridad"; echo 3 > /proc/sys/vm/drop_caches; comprobar /srv/raid5
    ;;
raid5-reconstruir)
    t "sdg se borra (como si fuera un disco nuevo) y se añade"
    mdadm --zero-superblock /dev/sdg; mdadm /dev/md5 --add /dev/sdg
    a=$(seg); sleep 1; mdadm --wait /dev/md5; echo "Reconstrucción de md5 (2 x 256 MB útiles): $(dur "$a")"
    mdadm --detail /dev/md5 | grep -E 'State :|Active|Working|/dev/sd'
    comprobar /srv/raid5
    ;;
espejo-crear)
    t "Iniciador iSCSI de deb-produccion y conexión al NAS ($NAS)"
    echo "InitiatorName=$IQN_CLI" > /etc/iscsi/initiatorname.iscsi
    systemctl restart iscsid
    iscsiadm -m discovery -t sendtargets -p $NAS
    iscsiadm -m node -T $IQN_NAS -p $NAS --op update -n node.startup -v automatic
    iscsiadm -m node -T $IQN_NAS -p $NAS --op update -n node.session.timeo.replacement_timeout -v 15
    iscsiadm -m node -T $IQN_NAS -p $NAS --login
    sleep 3; R=$(remoto)
    lsblk -o NAME,SIZE,TRAN,VENDOR,MODEL /dev/sdj "$R"
    t "RAID 1 (md10): sdj local + $R remoto (write-mostly: se lee del disco local)"
    wipefs -aq /dev/sdj "$R"
    mdadm --create /dev/md10 --run --level=1 --metadata=1.2 --bitmap=internal --raid-devices=2 /dev/sdj --write-mostly "$R"
    a=$(seg); sleep 1; mdadm --wait /dev/md10; echo "Sincronización inicial por la red: $(dur "$a")"
    mkfs.ext4 -F -q -L espejo /dev/md10 && mkdir -p /srv/espejo && mount /dev/md10 /srv/espejo
    datos /srv/espejo
    "$0" estado md10
    ;;
espejo-estado)
    t "Sesión iSCSI"; iscsiadm -m session 2>&1
    "$0" estado md10
    t "Datos"; echo 3 > /proc/sys/vm/drop_caches; comprobar /srv/espejo; ls /srv/espejo
    ;;
espejo-escribir)
    t "Escritura en /srv/espejo con el enlace al NAS cortado"
    a=$(seg); echo "escrito sin NAS $(date +%T)" > /srv/espejo/sin-nas.txt; sync; echo "La escritura terminó en $(dur "$a")"
    "$0" estado md10
    t "Mensajes del núcleo"; dmesg | grep -E 'connection1|md/raid1:md10|session recovery' | tail -5
    ;;
espejo-readd)
    R=$(remoto); D=${2:-$R}
    t "Se vuelve a añadir $D (el bitmap hace que solo se copie lo cambiado)"
    mdadm /dev/md10 --remove failed 2>/dev/null; mdadm /dev/md10 --remove detached 2>/dev/null
    a=$(seg); mdadm /dev/md10 --re-add "$D"; sleep 1; mdadm --wait /dev/md10; echo "Resincronización: $(dur "$a")"
    "$0" estado md10
    ;;
persistir)
    t "Configuración permanente: mdadm.conf, initramfs y fstab (nofail)"
    sed -i '/^ARRAY /d' /etc/mdadm/mdadm.conf
    mdadm --detail --scan >> /etc/mdadm/mdadm.conf
    grep ^ARRAY /etc/mdadm/mdadm.conf
    update-initramfs -u 2>&1 | tail -1
    sed -i '/\/srv\/raid\|\/srv\/espejo/d' /etc/fstab
    for n in 0 1 5; do echo "LABEL=raid$n /srv/raid$n ext4 defaults,nofail 0 2" >> /etc/fstab; done
    echo "LABEL=espejo /srv/espejo ext4 defaults,nofail,_netdev,x-systemd.requires=iscsi.service 0 2" >> /etc/fstab
    grep /srv/ /etc/fstab
    ;;
*) sed -n '2,10p' "$0"; exit 1 ;;
esac
