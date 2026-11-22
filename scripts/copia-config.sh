#!/bin/bash
# copia-config.sh · Copia la configuración de este equipo en el NAS (TrueNAS, recurso NFS)
# Tasca 5 (Apto+: automatizar las copias). Sirve para R3, el cliente Debian y los nodos Proxmox.
#
# Instalación:   install -m 750 copia-config.sh /usr/local/sbin/
#                + copia-config.service y copia-config.timer en /etc/systemd/system/
# Uso manual:    sudo copia-config.sh
# Resultado:     NAS:/mnt/copias/configuraciones/<equipo>/config-AAAAMMDD-HHMM.tar.gz
#                (+ lista de paquetes y suma SHA256). Se guardan las 7 últimas.
set -euo pipefail

NAS="192.168.30.20:/mnt/copias/configuraciones"
PUNTO=/mnt/copias
EQUIPO=$(hostname -s)
DESTINO="$PUNTO/$EQUIPO"
FECHA=$(date +%Y%m%d-%H%M)
GUARDAR=7

# Qué se copia: solo configuración (lo que no se recupera reinstalando desde la ISO)
RUTAS=(etc/hostname etc/hosts etc/fstab etc/network etc/NetworkManager/system-connections
       etc/resolv.conf etc/nftables.conf etc/sysctl.d etc/ssh/sshd_config etc/apt
       etc/sudoers.d etc/systemd/system etc/cron.d
       etc/pve etc/corosync)                 # las dos últimas solo existen en Proxmox
EXISTEN=()
for r in "${RUTAS[@]}"; do [ -e "/$r" ] && EXISTEN+=("$r"); done

montado_aqui=0
if ! mountpoint -q "$PUNTO"; then
    mkdir -p "$PUNTO"
    mount -t nfs -o vers=4,soft,timeo=50,retrans=2 "$NAS" "$PUNTO"
    montado_aqui=1
fi
trap 'if [ $montado_aqui = 1 ]; then umount "$PUNTO"; fi' EXIT

mkdir -p "$DESTINO"
# Qué NO se copia: claves privadas (del clúster, de SSH y certificados). No deben estar en una carpeta de red;
# si se pierden se regeneran (pvecm updatecerts, ssh-keygen -A).
tar -czf "$DESTINO/config-$FECHA.tar.gz" -C / --exclude='etc/pve/priv' --exclude='etc/pve/nodes/*/priv' --exclude='*.key' \
    --exclude='etc/ssh/ssh_host_*' "${EXISTEN[@]}"
dpkg --get-selections > "$DESTINO/paquetes-$FECHA.txt"
( cd "$DESTINO" && sha256sum "config-$FECHA.tar.gz" > "config-$FECHA.tar.gz.sha256" )

# Rotación: se borran las copias más antiguas que las 7 últimas
cd "$DESTINO"
ls -1t config-*.tar.gz | tail -n +$((GUARDAR + 1)) | while read -r viejo; do
    base=${viejo#config-}; base=${base%.tar.gz}
    rm -f "config-$base.tar.gz" "config-$base.tar.gz.sha256" "paquetes-$base.txt"
done

echo "Copia de $EQUIPO: $DESTINO/config-$FECHA.tar.gz ($(du -h --apparent-size "config-$FECHA.tar.gz" | cut -f1))"
cd /    # para poder desmontar el NFS al salir
