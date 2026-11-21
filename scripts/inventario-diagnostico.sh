#!/usr/bin/env bash
# Tasca 2 · Inventario y tests de diagnóstico del equipo anfitrión.
# Uso:   sudo bash scripts/inventario-diagnostico.sh casa      (o: clase)
# Paquetes necesarios (una vez):
#   sudo apt install smartmontools nvme-cli fio memtester sysbench
# Resultado: evidencies/T2-<equipo>/  (los números de serie, UUID y MAC se ocultan)
# Duración aproximada: 10-15 minutos. Mejor sin VMs encendidas y sin otros programas pesados.

set -u
EQUIPO="${1:?Indica el equipo: casa o clase}"
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/evidencies/T2-$EQUIPO"
mkdir -p "$OUT"
USUARIO="${SUDO_USER:-root}"
HOME_USR="$(getent passwd "$USUARIO" | cut -d: -f6)"
FIOFILE="$HOME_USR/.t2-fio-test"     # en /home → disco externo, donde están las VMs

# Oculta datos identificativos: serie, UUID, MAC
ocultar() { sed -E \
  -e 's/((Serial|serial|UUID|uuid|Serial Number|Asset Tag|SN)[[:space:]]*[:=][[:space:]]*).*/\1<oculto>/' \
  -e 's/(LU WWN Device Id:).*/\1 <oculto>/' \
  -e 's/([0-9a-fA-F]{2}[:o]){5}[0-9a-fA-F]{2}/<mac>/g' \
  -e "s#$HOME_USR/#~/#g" ; }
sec() { echo; echo "=================== $* ==================="; }
run() { echo "\$ $*"; "$@" 2>&1 | ocultar; echo; }

condiciones() {
  echo "Fecha: $(date '+%d/%m/%Y %H:%M:%S')"
  echo "Equipo: $EQUIPO · uptime: $(uptime -p) · carga: $(cut -d' ' -f1-3 /proc/loadavg)"
  echo "VMs en marcha: $(sudo -u "$USUARIO" VBoxManage list runningvms 2>/dev/null | wc -l)"
  echo "RAM libre: $(free -m | awk '/Mem:/{print $7" MB disponibles de "$2" MB"}')"
  command -v sensors >/dev/null && sensors 2>/dev/null | grep -E 'Package id 0|Composite|edge|Tctl' | head -3
}

########################## 1. INVENTARIO ##########################
{
sec "CONDICIONES"; condiciones
sec "RESUMEN (inxi)";            run inxi -Fxxz -c0
sec "PLACA, FIRMWARE Y ARRANQUE"
run dmidecode -t system -t baseboard -t bios -t chassis
echo "Modo de arranque: $([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS/Legacy)"
run mokutil --sb-state
sec "CPU Y VIRTUALIZACIÓN"
run lscpu
echo "Flags de virtualización: $(grep -o -w -E 'vmx|svm' /proc/cpuinfo | sort | uniq -c)"
echo "EPT/NPT: $(grep -o -w -E 'ept|npt' /proc/cpuinfo | sort -u | tr '\n' ' ')"
echo "Módulos KVM/VirtualBox cargados: $(lsmod | awk '/^(kvm|vbox)/{print $1}' | tr '\n' ' ')"
sec "RAM Y AMPLIACIÓN"
run dmidecode -t memory
run free -h
sec "DISCOS Y ESTADO"
run lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL,TRAN,ROTA
run df -hT -x tmpfs -x devtmpfs -x squashfs
for d in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}' | grep -v zram); do
  echo "--- SMART /dev/$d ---"
  S=$(smartctl -H -i -A "/dev/$d" 2>&1)
  # Los discos USB a veces necesitan indicar el puente SATA
  echo "$S" | grep -q -i -E 'specify device type|Unknown USB bridge' && S=$(smartctl -d sat -H -i -A "/dev/$d" 2>&1)
  echo "$S" | ocultar
  echo
done
sec "INTERFACES DE RED"
run ip -br link
run ip -br addr
for i in $(ls /sys/class/net | grep -v -E '^(lo|docker|vbox|veth|br-)'); do run ethtool "$i"; done
run lspci -nn
sec "USB Y PERIFÉRICOS"
run lsusb
run lsusb -t
command -v xrandr >/dev/null && sudo -u "$USUARIO" DISPLAY=:0 xrandr --listmonitors 2>/dev/null
sec "ALIMENTACIÓN"
run upower -d
echo "(La fuente de alimentación de un PC de sobremesa no se puede leer por software: anotar el modelo y la potencia de la etiqueta.)"
} > "$OUT/01-inventario.txt"
echo "✔ Inventario guardado en $OUT/01-inventario.txt"

########################## 2. TESTS ##########################
{
sec "CONDICIONES AL EMPEZAR"; condiciones

sec "MEMORIA · memtester 1 GB, 1 pasada"
echo "Herramienta: memtester $(memtester 2>&1 | head -1 | awk '{print $2}') · prueba desde el sistema en marcha (no sustituye a MemTest86+ en el arranque)"
T0=$(date +%s); memtester 1G 1 2>&1 | tr -d '\b' | sed -E 's/[|\/\\-]{3,}//g' | grep -v -E '^\s*$' ; echo "Duración: $(( $(date +%s) - T0 )) s"

sec "MEMORIA · ancho de banda (sysbench)"
run sysbench memory --memory-block-size=1M --memory-total-size=20G --threads=1 run
run sysbench memory --memory-block-size=1M --memory-total-size=40G --threads="$(nproc)" run

sec "CPU · sysbench (referencia para la virtualización)"
run sysbench cpu --cpu-max-prime=20000 --threads=1 --time=15 run
run sysbench cpu --cpu-max-prime=20000 --threads="$(nproc)" --time=15 run

sec "DISCO · lectura secuencial sin caché (hdparm, solo lectura)"
for d in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}' | grep -v zram); do run hdparm -t "/dev/$d"; done

sec "DISCO EXTERNO (donde están las VMs) · fio sobre $FIOFILE"
echo "Fichero de prueba de 1 GB, E/S directa (sin caché de página)."
for job in "seq-lectura:read:1M" "seq-escritura:write:1M" "aleat-lectura-4k:randread:4k" "aleat-escritura-4k:randwrite:4k"; do
  IFS=: read -r nombre rw bs <<<"$job"
  echo "--- $nombre ($rw, bloque $bs) ---"
  fio --name="$nombre" --filename="$FIOFILE" --size=1G --rw="$rw" --bs="$bs" --direct=1 \
      --ioengine=libaio --iodepth=16 --runtime=20 --time_based --group_reporting 2>&1 \
      | grep -E 'IOPS=|lat \(usec\): min|lat \(msec\): min|clat percentiles|99.00th' | head -4
done
rm -f "$FIOFILE"

sec "RED · enlace"
for i in $(ls /sys/class/net | grep -v -E '^(lo|docker|vbox|veth|br-)'); do
  echo "$i: velocidad $(cat /sys/class/net/$i/speed 2>/dev/null) Mb/s · duplex $(cat /sys/class/net/$i/duplex 2>/dev/null) · errores rx/tx $(cat /sys/class/net/$i/statistics/rx_errors)/$(cat /sys/class/net/$i/statistics/tx_errors)"
done
GW=$(ip r | awk '/^default/{print $3; exit}')
sec "RED · latencia a la puerta de enlace ($GW), 20 pings"; run ping -c20 -i0.2 "$GW"
sec "RED · latencia a Internet (1.1.1.1), 10 pings";       run ping -c10 -i0.5 1.1.1.1
sec "RED · resolución DNS"
for h in deb.debian.org github.com; do t0=$(date +%s%N); getent hosts "$h" >/dev/null && r=ok || r=FALLO; echo "$h: $r en $(( ($(date +%s%N) - t0) / 1000000 )) ms"; done
sec "RED · descarga de 100 MiB (proof.ovh.net), 3 pasadas"
for i in 1 2 3; do
  curl -s -o /dev/null -m 120 -w "Pasada $i: HTTP %{http_code} · %{size_download} bytes en %{time_total} s · %{speed_download} B/s\n" \
    'https://proof.ovh.net/files/100Mb.dat'
done

sec "CONDICIONES AL ACABAR"; condiciones
} > "$OUT/02-tests.txt" 2>&1
echo "✔ Tests guardados en $OUT/02-tests.txt"

chown -R "$USUARIO": "$OUT"
