# 07 · Rendimiento y diagnóstico

Tasca 7 «Rendiment i diagnòstic» · RA principales: ISO RA6 a-h y FDM RA1 e-g · **Parte individual**.

> Grupo 3 · Medidas: 22/11/2026, 13:38–14:21 (PC de casa) · Línea base sin VMs: [Tasca 2](02-inventari.md#5-tests-de-diagnóstico-apte--pc-de-casa)
> Herramienta: [scripts/t7-muestreo.py](../scripts/t7-muestreo.py) · Evidencias: [t7-escenarios-anfitrion](../evidencies/t7-escenarios-anfitrion-20261122.txt) · [t7-optimizaciones](../evidencies/t7-optimizaciones-antes-despues-20261122.txt)

## 1. Qué pedía la Tasca 7 y dónde está

La parte individual pide analizar los recursos de **mi máquina física**: qué VMs saturan cada recurso y cuántas
puedo arrancar y usar sin bloquear el equipo. La comparación de cada equipo con su línea base trabajando es del
grupo.

| Lo que se pide | Nivel | Dónde está | Estado |
|---|---|---|---|
| Medir CPU, RAM, disco y red durante las cargas previstas | Apte | [3](#3-escenarios-medidos) · [t7-escenarios-anfitrion](../evidencies/t7-escenarios-anfitrion-20261122.txt) | ✅ Hecho |
| Interpretar las medidas e identificar los recursos saturados | Apte | [4](#4-qué-satura-cada-máquina-virtual) | ✅ Hecho |
| Analizar los recursos físicos con distintas cargas de VM | Apte | [3](#3-escenarios-medidos) · [4](#4-qué-satura-cada-máquina-virtual) | ✅ Hecho |
| Determinar la capacidad del hardware y cuántas VMs se pueden usar sin bloquear el equipo | Apte | [5](#5-cuántas-vms-puedo-usar-sin-bloquear-el-equipo) | ✅ Hecho |
| Entregar el informe de medidas y conclusiones | Apte | Este documento · [8](#8-conclusiones) | ✅ Hecho |
| Proponer y aplicar una primera optimización de las VM | Apte+ | [6.1](#61-optimización-1-el-cliente-tardaba-2-minutos-en-arrancar) | ✅ Hecho |
| Proponer y aplicar una segunda optimización de las VM | Apte+ | [6.2](#62-optimización-2-r3-saturaba-su-cpu-al-enrutar) | ✅ Hecho |
| Comparar las medidas de rendimiento antes y después | Apte+ | [6.3](#63-comparación-antes-y-después) · [t7-optimizaciones](../evidencies/t7-optimizaciones-antes-despues-20261122.txt) | ✅ Hecho |

## 2. Cómo se ha medido

**El equipo:** el PC de casa, con un Intel Core i7-8700 (6 núcleos y 12 hilos), **16 GB de RAM** y las VMs en un
SSD externo por USB a 5 Gb/s (430/403 MiB/s medidos en la [Tasca 2](02-inventari.md)). El sistema es Linux Mint con
VirtualBox 7.2.

**Las condiciones:** el PC tenía abiertas las aplicaciones de uso normal (navegador, editor y música), porque así es
como trabajo con el entorno. Esas aplicaciones ocupan unos **4,5 GB**: sin ninguna VM quedan **11,4 GB
disponibles**.

**Las herramientas.** En el anfitrión no está `sysstat` (sin `iostat`, `sar` ni `pidstat`), así que escribí
[t7-muestreo.py](../scripts/t7-muestreo.py), que lee lo mismo que esas herramientas directamente de `/proc`. Cada
5 s apunta:

| Recurso | Dato | De dónde sale (equivalente) |
|---|---|---|
| CPU | % ocupado y % de espera de E/S | `/proc/stat` (`vmstat`, `mpstat`) |
| RAM | Disponible y swap usada (zram + fichero) | `/proc/meminfo` (`free`) |
| Saturación | Presión PSI de CPU, memoria y E/S: % del tiempo con tareas esperando | `/proc/pressure/*` |
| Disco externo | MB/s leídos y escritos, % de ocupación | `/proc/diskstats` (`iostat -x`) |
| **¿Se bloquea el PC?** | Lo que tarda en lanzar un proceso (`fork_ms`) y en escribir 4 KiB a disco (`fsync_ms`) | Prueba propia |
| Cada VM | % de CPU, en % de un hilo (100 = un hilo entero), y RAM | `/proc/<pid>` del proceso `VBoxHeadless` |

Dentro de los sistemas se usaron `vmstat`, `journalctl -p err -b`, `/proc/diskstats`, `systemd-analyze` y
`pveperf`. La red se midió con descargas de 100 MB desde el cliente a través de cada router.

**Una lección del método.** La RAM residente del proceso VirtualBox **no** dice cuánto ocupa una VM. Por ejemplo:

- El NAS aparecía con 866 MB, pero al encenderlo la RAM disponible del PC bajó unos 2,9 GB.
- El cliente Debian marcaba 1.380 MB y al apagarlo liberó 2.206 MB.

Por eso la RAM de cada VM se mide por la **diferencia de RAM disponible al encenderla o apagarla**.

## 3. Escenarios medidos

| Escenario | VMs encendidas | Carga | CPU del PC (media / máx.) | RAM disponible | Disco externo (máx.) | ¿Responde el PC? (`fsync` máx.) |
|---|---|---|---|---|---|---|
| **E0** · Base | Ninguna | Aplicaciones normales | 7,9 % / 8,7 % | 11.416 MB | 0 MB/s | 2,8 ms ✅ |
| **E1a** · Arranque de comunicaciones | R1 + R2 + R3 + cliente | Arrancan las 4 a la vez | 12,5 % / 29,7 % | 9.148 MB | 26,8 MB/s · 25,6 % | 8,6 ms ✅ |
| **E1b** · Routers enrutando | Las mismas | Descarga de 100 MB por R3, R2 y R1 | 15,1 % / 23,1 % | 8.449 MB | 0 MB/s | 4,8 ms ✅ |
| **E2a** · Arranque del NAS | + NAS | Arranca TrueNAS | 11,8 % / 19,2 % | 6.440 MB | 19,9 MB/s | 4,5 ms ✅ |
| **E2b** · Servidor de copias trabajando | Las mismas | El cliente copia 2 × 500 MB al NAS por NFS | 11,9 % / 22,4 % | 4.816 MB | **95 MB/s escritura** · 23,8 % | 14,5 ms ✅ |
| **E3a** · Arranque de WS2025 | R1 + NAS + WS2025 | Arranca Windows Server | 11,6 % / 20,4 % | 6.003 MB | 73,7 MB/s · **69 %** | 5,7 ms ✅ |
| **E3b** · Arranque de W11 | + W11 | Arranca Windows 11 | 14,4 % / 21,4 % | **1.625 MB** | **158,5 MB/s** · 70 % | 4,2 ms ✅ |
| **E5** · Límite en casa | R1 + R3 + NAS + WS2025 + W11 | Todo en reposo | 12,9 % / 13,6 % | **1.263 MB** · zram 1,4 GB | 5,9 MB/s | 4,2 ms ✅ (`fork` 1,2 ms) |
| **E4a** · Arranque del clúster | R1 + R3 + NAS + PVE-1/2/3 | Arrancan los 3 nodos a la vez | 19,8 % / 37,7 % | 3.268 MB | 125 MB/s · **91 %** | **93,8 ms** ⚠️ |
| **E4b** · Clúster trabajando | Las mismas | `pveperf` en los 3 nodos a la vez | 18,3 % / 31,1 % | 3.302 MB | **200 MB/s lectura · 155 MB/s escritura** · 63 % · 16 % de espera de E/S | 6,1 ms ✅ |

**Red** (E1b, descarga de 100 MB desde el cliente, en Mb/s):

| Router | Velocidad | CPU de la VM (máx., % de un hilo) | Interpretación |
|---|---|---|---|
| R1 MikroTik CHR | **0,9 Mb/s** | 11 % | El límite es la licencia gratuita del CHR (1 Mb/s), no el PC |
| R2 OPNsense | **614 Mb/s** | 45 % | Casi el máximo de la conexión de casa (~660 Mb/s, Tasca 2) |
| R3 Debian nftables | **150 Mb/s** | **180–251 %** | **Saturado de CPU**: es la VM que más trabaja por cada Mb/s ([6.2](#62-optimización-2-r3-saturaba-su-cpu-al-enrutar)) |

**Dentro de los sistemas** (tras el `pveperf`):

- `vmstat` en pve1 muestra **478 MB en swap**, aunque el nodo está vacío: los 1,5 GB que tiene asignados le van
  justos.
- R3 tiene 7 líneas de error en `journalctl -p err -b`, todas inofensivas: el aviso del controlador gráfico `vmwgfx`
  y `blkmapd` sin NFS de bloques.
- pve1 no tiene ningún error.

## 4. Qué satura cada máquina virtual

RAM medida por la diferencia de RAM disponible al encender o apagar cada VM:

| VM | RAM asignada | RAM real en el PC | CPU en el arranque (máx.) | Disco en el arranque (máx.) | Recurso que más satura |
|---|---|---|---|---|---|
| R1 MikroTik | 256 MB | ~150 MB | 61 % | — | Nada (la red está limitada por la licencia) |
| R2 OPNsense | 1 GB | **1.056 MB** | 93 % | — | RAM para lo poco que hace |
| R3 Debian nftables | 512 MB | 352–379 MB | 101 % | — | **CPU** al enrutar (antes de la optimización) |
| NAS TrueNAS | 3 GB | **~2,9 GB** (calculado en E5) | **198 %** (2 vCPU llenas) | 20 MB/s · escribe hasta 95 MB/s al recibir copias | **RAM** (ZFS usa la libre como caché) y CPU al arrancar |
| WS2025 | 2 GB | **2.149–2.417 MB** | 190 % | 74 MB/s · 69 % | RAM y disco al arrancar |
| W11 | 4 GB | **4.337–4.918 MB** | **206 %** | **158 MB/s** · 70 % | **RAM** (la que más) y disco al arrancar · en reposo sigue gastando 34 % de un hilo |
| Cliente Debian | 2 GB | **2.206 MB** | 102 % | — | RAM · arranque lento si falta el NAS ([6.1](#61-optimización-1-el-cliente-tardaba-2-minutos-en-arrancar)) |
| PVE-1/2/3 | 1,5 GB c/u | **~1.630 MB c/u** | 136–143 % c/u | Los 3 a la vez: **125 MB/s · 91 %** | **RAM** (swap dentro) y **disco** si arrancan juntos |

Resumen por recurso del PC:

| Recurso | ¿Se satura? | Cuándo | Dato |
|---|---|---|---|
| **RAM** | ✅ **Sí, es el límite** | Con 5 VMs (las dos Windows y el NAS) | Quedan 1,26 GB disponibles y el zram ya guarda 1,4 GB comprimidos |
| **Disco externo** | ⚠️ **En picos** | Al arrancar varias VMs a la vez (sobre todo los 3 nodos o Windows) | 91 % de ocupación y `fsync` del PC a 94 ms: es cuando **se nota lento** |
| **CPU** | ❌ No | Nunca pasó del 38 % de los 12 hilos | El pico fue el arranque del clúster |
| **Red** | ❌ No en el PC | Solo dentro de las VMs | El límite era R1 (licencia) y R3 (su vCPU) |

La presión de memoria (PSI) se quedó en **0** incluso en E5. Linux todavía no tenía que esperar para conseguir
memoria, gracias al zram. El paso siguiente sería empezar a usar el fichero de swap del disco externo, y ahí sí se
bloquearía el PC. No lo provoqué a propósito, para no colgar el equipo.

## 5. ¿Cuántas VMs puedo usar sin bloquear el equipo?

**Presupuesto:** 11,4 GB disponibles sin VMs, dejando **1,2 GB de margen** para que el PC no empiece a usar el swap
del disco. Quedan unos **10 GB para las VMs**.

| Combinación | VMs | RAM real | Margen | Resultado |
|---|---|---|---|---|
| Comunicaciones + cliente (E1) | 4 | ~3,0 GB | ~8,4 GB | ✅ Sobrado |
| Comunicaciones + NAS + cliente (E2) | 5 | ~6,6 GB | ~4,8 GB | ✅ |
| **R1 + R3 + NAS + WS2025 + W11** (E5) | **5** | **~10,1 GB** | **1,26 GB** | ✅ **Al límite**: no cabe nada más |
| R1 + R3 + NAS + PVE-1/2/3 (E4) | 6 | ~8,1 GB | ~3,3 GB | ✅ |
| E4 + cliente Debian | 7 | ~10,3 GB | ~1,1 GB | ⚠️ Al límite (estimado) |
| Escenario B del diseño (R1 + NAS + WS2025 + W11 + Debian) | 5 | ~12 GB | Negativo | ❌ **No cabe** con las aplicaciones abiertas |
| Las 10 VMs | 10 | ~18,5 GB | Negativo | ❌ Solo en el PC de clase (30 GB) |

**Conclusión:** puedo trabajar a la vez con **5 a 7 VMs**, según cuáles sean. El número no es lo importante: lo es la
**RAM**. Las dos Windows juntas ya se llevan 6,5–7 GB, y con ellas solo caben el NAS y dos routers.

Esto corrige dos datos anteriores:

- El escenario B de la [Tasca 0](00-entorno-pruebas.md#8-cuántas-máquinas-se-pueden-arrancar-a-la-vez) se dio como
  «cabe justo», pero suponía 13 GB libres para las VMs; con las aplicaciones abiertas solo hay 11,4 GB.
- La reserva para el anfitrión, que se estimó en 3 GB, es en realidad de **4,5 GB**.

**Reglas que salen de las medidas:**

1. **No arrancar a la vez** varias VMs pesadas (los 3 nodos, o las dos Windows): de una en una, el disco no pasa del
   70 % y el PC no se nota.
2. **Las Windows de una en una** cuando también hace falta el cliente Debian.
3. Cerrar el navegador y la música antes de un escenario grande libera unos 2 GB, que es exactamente una Windows
   Server más.

## 6. Optimizaciones (Apte+)

### 6.1 Optimización 1: el cliente tardaba 2 minutos en arrancar

- **Problema detectado:** al encender el cliente Debian con el NAS apagado, tardaba **2 min 17 s** en arrancar, y
  los primeros intentos de SSH fallaban con «System is booting up».
- **Diagnóstico** (`systemd-analyze blame` y `journalctl -u open-iscsi`): `open-iscsi.service` se llevaba **2 min
  1 s**. Intentaba conectarse al disco iSCSI del espejo de la [Tasca 6](06-recuperacio.md#6-espejo-entre-discos-de-dos-equipos-distintos-apte),
  y los valores por defecto son `initial_login_retry_max = 8` y `login_timeout = 15`, es decir, 8 × 15 s = 120 s.
- **Cambio aplicado:**
  `iscsiadm -m node -T … --op update -n node.session.initial_login_retry_max -v 1` y `… -n node.conn[0].timeo.login_timeout -v 5`.
- **Contrapartida:** si el NAS está apagado al arrancar, el espejo empieza con un solo disco y hay que reconectarlo a
  mano cuando vuelva el NAS (`iscsiadm … --login` + `mdadm /dev/md10 --re-add`). Se comprobó: el disco se
  reincorporó y las sumas de los datos coinciden.

### 6.2 Optimización 2: R3 saturaba su CPU al enrutar

- **Problema detectado:** R3 solo pasaba **150–169 Mb/s** mientras R2, en el mismo PC, pasaba 614 Mb/s. El proceso
  de R3 gastaba de media un hilo entero y hasta el **251 %** en los picos: la VM tiene 1 vCPU y no daba más.
- **Diagnóstico:** R3 usaba tarjetas **virtio**; R1 y R2 usan la **Intel PRO/1000 (82540EM)** emulada. En
  VirtualBox, virtio no siempre es la tarjeta más eficiente; aquí la duda era si gastaba más CPU por paquete que la
  Intel, y la medida de después lo confirma.
- **Cambio aplicado:**
  `VBoxManage modifyvm R3-Debian-nftables --nictype1 82540EM --nictype2 82540EM` (con la VM apagada). Los nombres
  `enp0s3`/`enp0s8` dependen de la ranura PCI y no cambiaron, así que las reglas de nftables siguieron funcionando
  sin tocarlas.
- **Optimización descartada:** bajar la RAM de los nodos Proxmox. Usan 1,22 GB de sus 1,46 GB vacíos y ya hacen swap
  por dentro, así que bajarla los habría empeorado.

### 6.3 Comparación antes y después

| Optimización | Medida | Antes | Después | Mejora |
|---|---|---|---|---|
| 1 · open-iscsi | Arranque del cliente con el NAS apagado (`systemd-analyze`) | **2 min 17,6 s** | **21,0 s** | **−85 %** (6,5 veces más rápido) |
| 1 · open-iscsi | Tiempo de `open-iscsi.service` | 2 min 1,3 s | 7,1 s | −94 % |
| 2 · Tarjeta de R3 | Velocidad por R3 (6 descargas de 100 MB) | 150 · 169 · 163 Mb/s | 277 · 744 · 133 · **690 · 691 · 708** Mb/s | **×4** (hasta el máximo de la conexión) |
| 2 · Tarjeta de R3 | CPU de R3 en el PC durante las descargas (media / máx.) | **99 % / 251 %** de un hilo | **20 % / 44–75 %** | **−80 %** |
| 2 · Tarjeta de R3 | CPU total del PC (media) | 16,5 % | 10,6–11,0 % | −35 % |

Con la tarjeta Intel, 5 de las 6 descargas fueron más rápidas que la mejor con virtio. La de 133 Mb/s coincidió con
una bajada de la conexión de casa (no hay pico de CPU en R3), y la segunda tanda dio 690–708 Mb/s las tres veces.

## 7. Problemas encontrados y solución

| # | Problema | Causa | Solución |
|---|---|---|---|
| 1 | El anfitrión no tiene `iostat`, `sar` ni `pidstat` | `sysstat` no está instalado en el anfitrión | Muestreador propio que lee `/proc` ([t7-muestreo.py](../scripts/t7-muestreo.py)) |
| 2 | La RAM del proceso VirtualBox no cuadraba con la RAM gastada | Probablemente VirtualBox reserva parte de la RAM de la VM a través de su controlador del núcleo, fuera de la memoria residente del proceso | Medir la diferencia de RAM disponible al encender o apagar cada VM |
| 3 | `wget` se iba a segundo plano y la descarga por HTTP redirigía a HTTPS | Sesión SSH con terminal; y sin DNS en casa no se resuelve el nombre de la redirección | Descarga en Python por HTTPS directa a la IP (con el nombre en SNI) |
| 4 | W11 y WS2025 no se apagaban con el botón ACPI | En la pantalla de bloqueo, Windows ignora el botón de apagado | Se guardó su estado (`savestate`); se reanudan donde estaban |

## 8. Conclusiones

1. **El recurso que limita mi PC es la RAM**, no la CPU ni la red: la CPU nunca pasó del 38 %.
2. **Las VMs que más pesan son las Windows**, sobre todo W11, con unos 4,3–4,9 GB. Después vienen el NAS (~2,9 GB)
   y los nodos Proxmox (~1,6 GB cada uno). Los routers casi no cuentan, salvo R2 (1 GB).
3. **El disco externo solo se satura en los arranques simultáneos.** Es el único momento en que se nota el PC lento
   (`fsync` de 2 a 94 ms). Arrancar las VMs de una en una lo evita.
4. **Capacidad:** de 5 a 7 VMs a la vez con 1,2 GB de margen, según cuáles. Las 10 juntas necesitarían unos 18,5 GB,
   así que en casa se trabaja por escenarios. Ampliar a 32 GB, como se propuso en la Tasca 2, lo resolvería.
5. **Medir sirve para optimizar.** Dos cambios pequeños, encontrados al mirar las medidas, dieron un arranque 6,5
   veces más rápido y un router 4 veces más rápido con una quinta parte de CPU.

**Predicción** (antes de medir): «La CPU será el problema, porque hay 17 vCPU para 12 hilos». **No se cumplió:** la
CPU sobra. El límite es la RAM, como ya indicaba la Tasca 2. Lo que no esperaba es que el disco externo frenara el PC
en los arranques, ni que una tarjeta de red virtual cambiara tanto el rendimiento de un router.
