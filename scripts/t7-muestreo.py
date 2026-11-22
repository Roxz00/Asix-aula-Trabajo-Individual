#!/usr/bin/env python3
"""t7-muestreo.py · Medidas del anfitrión para la Tasca 7 (sin sysstat: lee /proc directamente).

Uso:  python3 scripts/t7-muestreo.py ETIQUETA SEGUNDOS [INTERVALO=5] > salida.txt

Cada intervalo apunta:
  · CPU del anfitrión (% ocupado y % de espera de E/S), como vmstat
  · RAM disponible, swap usada (zram + fichero) y presión PSI de CPU, memoria y E/S (avg10)
  · disco externo (sdb): MB/s leídos y escritos y % de ocupación, como iostat -x
  · respuesta del anfitrión: tiempo de arrancar un proceso y de escribir 4 KiB + fsync en /home
  · por cada VM (proceso VBoxHeadless o VirtualBoxVM): % de CPU, RAM residente y en swap
Al final saca un resumen (media y máximo). Protección: si MemAvailable < 1,2 GB lo avisa con «¡ALERTA!».
"""
import os, subprocess, sys, time

DISCO = "sdb"
ETIQ, DURA = sys.argv[1], int(sys.argv[2])
PASO = int(sys.argv[3]) if len(sys.argv) > 3 else 5
HZ = os.sysconf("SC_CLK_TCK")
NCPU = os.cpu_count()

def cpu():
    v = list(map(int, open("/proc/stat").readline().split()[1:9]))
    return sum(v), v[3] + v[4], v[4]          # total, idle+iowait, iowait

def mem():
    d = {l.split(":")[0]: int(l.split()[1]) for l in open("/proc/meminfo")}
    return d["MemAvailable"] / 1024, (d["SwapTotal"] - d["SwapFree"]) / 1024

def psi(r):
    l = open(f"/proc/pressure/{r}").readline()           # «some avg10=…»
    return float(l.split()[1].split("=")[1])

def disco():
    for l in open("/proc/diskstats"):
        c = l.split()
        if c[2] == DISCO:
            return int(c[5]), int(c[9]), int(c[12])         # sectores leídos, escritos, ms ocupado
    return 0, 0, 0

def vms():
    r = {}
    for p in os.listdir("/proc"):
        if not p.isdigit(): continue
        try:
            a = open(f"/proc/{p}/cmdline").read().split("\0")
            if not a[0].endswith(("VBoxHeadless", "VirtualBoxVM")) or "--comment" not in a: continue
            nombre = a[a.index("--comment") + 1] + ("" if a[0].endswith("VBoxHeadless") else " (ventana)")
            st = open(f"/proc/{p}/stat").read().rsplit(")", 1)[1].split()
            s = {l.split(":")[0]: l.split()[1] for l in open(f"/proc/{p}/status") if l.startswith(("VmRSS", "VmSwap"))}
            r[nombre] = (int(st[11]) + int(st[12]), int(s.get("VmRSS", 0)) / 1024, int(s.get("VmSwap", 0)) / 1024)
        except (OSError, ValueError, IndexError):
            pass
    return r

def respuesta():
    t = time.perf_counter(); subprocess.run(["/bin/true"]); fork = (time.perf_counter() - t) * 1000
    f = os.path.expanduser("~/.t7-latencia"); t = time.perf_counter()
    with open(f, "wb") as h: h.write(os.urandom(4096)); h.flush(); os.fsync(h.fileno())
    fs = (time.perf_counter() - t) * 1000; os.remove(f)
    return fork, fs

print(f"# Tasca 7 · {ETIQ} · {time.strftime('%d/%m/%Y %H:%M:%S')} · {DURA} s cada {PASO} s · {NCPU} hilos · disco {DISCO}")
print("hora     cpu%  iow%  disp_MB swap_MB psi_cpu psi_mem psi_io  rd_MB/s wr_MB/s util%  fork_ms fsync_ms")
c0, d0, v0, t0 = cpu(), disco(), vms(), time.time()
filas, porvm = [], {}
for _ in range(DURA // PASO):
    time.sleep(PASO)
    c1, d1, v1, t1 = cpu(), disco(), vms(), time.time()
    dt = c1[0] - c0[0] or 1
    ocup = 100 * (1 - (c1[1] - c0[1]) / dt); iow = 100 * (c1[2] - c0[2]) / dt
    disp, swap = mem(); seg = t1 - t0
    rd = (d1[0] - d0[0]) * 512 / 1e6 / seg; wr = (d1[1] - d0[1]) * 512 / 1e6 / seg
    util = min(100, (d1[2] - d0[2]) / 10 / seg)
    fk, fs = respuesta()
    fila = (ocup, iow, disp, swap, psi("cpu"), psi("memory"), psi("io"), rd, wr, util, fk, fs)
    filas.append(fila)
    print(time.strftime("%H:%M:%S"), " ".join(f"{x:7.1f}" for x in fila), "  ¡ALERTA! RAM < 1,2 GB" if disp < 1200 else "", flush=True)
    for n, (tk, rss, sw) in v1.items():
        if n in v0:
            porvm.setdefault(n, []).append((100 * (tk - v0[n][0]) / HZ / seg, rss, sw))
    c0, d0, v0, t0 = c1, d1, v1, t1

nombres = ["cpu%", "iow%", "disp_MB", "swap_MB", "psi_cpu", "psi_mem", "psi_io", "rd_MB/s", "wr_MB/s", "util%", "fork_ms", "fsync_ms"]
print(f"\n## Resumen del anfitrión ({len(filas)} muestras)")
print("dato        media    máximo   mínimo")
for i, n in enumerate(nombres):
    col = [f[i] for f in filas]
    print(f"{n:9} {sum(col)/len(col):8.1f} {max(col):9.1f} {min(col):8.1f}")
print("\n## Por VM (CPU en % de un hilo: 100 = un hilo entero; RAM en MB)")
print(f"{'VM':34} {'cpu_media':>9} {'cpu_max':>8} {'RAM_res':>8} {'en_swap':>8} {'total':>7}")
tot = [0, 0, 0]
for n, m in sorted(porvm.items()):
    cm = sum(x[0] for x in m) / len(m); rss, sw = m[-1][1], m[-1][2]
    tot = [tot[0] + cm, tot[1] + rss, tot[2] + sw]
    print(f"{n:34} {cm:9.1f} {max(x[0] for x in m):8.1f} {rss:8.0f} {sw:8.0f} {rss+sw:7.0f}")
print(f"{'TOTAL VMs':34} {tot[0]:9.1f} {'':8} {tot[1]:8.0f} {tot[2]:8.0f} {tot[1]+tot[2]:7.0f}")
