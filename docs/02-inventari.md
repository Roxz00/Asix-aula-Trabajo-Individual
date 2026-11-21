# Tasca 2 · Inventario y diagnóstico de los equipos (individual)

> Grupo 3 · Equipos: **PC de casa** y **PC de clase** · Fecha: 21/11/2026
> Herramienta de recogida: [scripts/inventario-diagnostico.sh](../scripts/inventario-diagnostico.sh)
> (inxi, dmidecode, lscpu, smartctl, ethtool, lsusb, memtester, sysbench, hdparm, fio, ping, curl).
> Evidencias completas: [evidencies/T2-casa/01-inventario.txt](../evidencies/T2-casa/01-inventario.txt) ·
> [evidencies/T2-casa/02-tests.txt](../evidencies/T2-casa/02-tests.txt).
> Los números de serie, UUID y MAC se ocultan porque el repositorio es público.

## 1. Qué pide la tarea

- **Apte:** inventariar el equipo de clase y el de casa, compararlos, identificar los cuellos de botella
  de cada uno y proponer soluciones.
- **Apte+:** hacer tests de memoria, disco y red en los dos equipos, apuntar la herramienta, las
  condiciones y el resultado, y justificar con los datos si cada cuello de botella se confirma o no.

> **Limitación.** El PC de clase no se pudo volver a examinar: la entrega es el domingo 22/11 y el aula
> está cerrada. Sus datos salen de lo que se registró durante el montaje (17 y 19/11). Lo que no se
> registró se marca como **N/C** (no confirmado). Los tests del Apte+ se hicieron **solo en el PC de casa**.

Los dos equipos arrancan **el mismo sistema**: Linux Mint 22.3 en un SSD externo USB de 512 GB, donde
están también las VMs. Lo que cambia es el hardware que hay alrededor del disco.

## 2. Inventario

| Apartado | PC de casa | PC de clase | Fuente |
|---|---|---|---|
| **Formato** | Sobremesa, caja de torre (*chassis type* 3: Desktop) | N/C. Tiene wifi (`wlp1s0`) y una CPU de portátil (serie H): probablemente un mini PC o portátil | dmidecode · `ip` |
| **Placa base** | ASUS PRIME Z370-P (chipset Intel Z370) | N/C | dmidecode |
| **Firmware y arranque** | UEFI AMI 3004 (07/12/2021) · **Secure Boot activado** · arranque UEFI | UEFI con Secure Boot (la clave MOK de VirtualBox ya estaba registrada) | dmidecode · mokutil |
| **CPU** | Intel Core i7-8700 (Coffee Lake, 2017) · **6 núcleos / 12 hilos** · 3,2–4,6 GHz · 12 MiB de L3 | Intel Core Ultra 5 125H (Meteor Lake, 2023) · **14 núcleos híbridos (4 P + 8 E + 2 LP-E) / 18 hilos** | lscpu · API de TrueNAS · `nproc` |
| **Virtualización** | VT-x + EPT activas; módulos `kvm_intel` y `vboxdrv` cargados | VT-x activa (los nodos Proxmox anidados funcionaron) | /proc/cpuinfo · lsmod |
| **RAM** | **16 GB** = 2 × 8 GB DDR4-2667 Crucial Ballistix (BLS8G4D26BFS…), doble canal (A2 + B2), sin ECC | **~32 GB** (31.331 MB visibles) · tipo y ranuras N/C | dmidecode · free |
| **Ampliación de RAM** | **4 ranuras, 2 libres** (A1 y B1) · máximo **64 GB** | N/C | dmidecode |
| **Disco del sistema y de las VMs** | SSD externo 512 GB por **USB a 5 Gb/s** (controlador Intel de la serie 200, UAS) · caja con puente **VIA VL716** | El mismo SSD · velocidad del puerto N/C | lsusb -t · smartctl |
| **Discos internos** | NVMe **WD_BLACK SN770 1 TB**: admite PCIe 4.0, pero la placa lo enlaza a **PCIe 3.0 x4** (8 GT/s, `current_link_speed`) · SATA **Kingston A400 480 GB** | N/C (no había ningún disco SATA antes del externo, que aparecía como `sda`) | lsblk · smartctl |
| **Estado de los discos** | Ver § 2.1 | N/C | smartctl |
| **Red** | Realtek RTL8111H **1 Gb/s**, full duplex, 0 errores · IP por DHCP del router de casa | `eno1` por cable (172.16.222.47/24, DHCP del centro) + wifi `wlp1s0` sin usar | ethtool · ip |
| **Gráfica** | NVIDIA GeForce GTX 1660 SUPER (ZOTAC) | Integrada (Intel Arc de la Ultra 5) · N/C | inxi · lspci |
| **Periféricos** | Monitores AOC 24G2W1G4 y BenQ G2420HD (1920×1080 c/u) · teclado Ducky One 3 Mini · ratón Razer Orochi V2 · webcam A4Tech HD Pro · micrófono USB MC5 · mando DualShock 4 | N/C | inxi · lsusb |
| **Alimentación** | Fuente interna ATX: modelo y potencia **N/C** (no se pueden leer por software; hay que mirar la etiqueta) · estado de la fuente según el firmware: *Safe* | N/C | dmidecode · upower |
| **Temperaturas** | CPU 34 °C en reposo → 40 °C tras los tests · NVMe 37 °C · disco externo 40 °C | N/C | sensors · smartctl |
| **Documentación** | [Manual ASUS PRIME Z370-P](https://www.asus.com/motherboards-components/motherboards/prime/prime-z370-p/) · [ficha del i7-8700](https://www.intel.com/content/www/us/en/products/sku/126686/intel-core-i78700-processor-12m-cache-up-to-4-60-ghz/specifications.html) | [Fichas de Intel (buscar «125H»)](https://ark.intel.com/content/www/us/en/ark/search.html?q=125H) | — |

### 2.1 Estado de los discos (SMART, PC de casa)

| Disco | Uso en el proyecto | Salud | Horas | Desgaste | Otros datos |
|---|---|---|---|---|---|
| SSD externo 512 GB (USB) | **Sistema + VMs** | ✅ PASSED | 475 h | 0 sectores reasignados, 0 pendientes | 40 °C |
| WD_BLACK SN770 1 TB (NVMe) | No (es del PC de casa) | ✅ PASSED | 5.410 h | **1 % usado**, 100 % de reserva | 0 errores de medio · 1 entrada en el registro de errores · 38 apagados bruscos |
| Kingston A400 480 GB (SATA) | No | ✅ PASSED | 13.443 h | ⚠️ **81 % de vida restante** (51 TB escritos) | 0 errores de programación o borrado · 164 apagados bruscos |

**Posible avería a vigilar.** El NVMe tiene **1 entrada en el registro de errores**, pero **0 errores
de medio o de integridad**.
- **Causa probable:** un comando que el controlador no admite al arrancar. Es habitual y no afecta a los
  datos.
- **Cómo distinguirlo de un fallo real:** `sudo nvme error-log /dev/nvme0n1` muestra el código del error.
  Si es *Invalid Field/Opcode* es el caso benigno. Si fuera de lectura o escritura y el contador
  *Media and Data Integrity Errors* subiera, sería un fallo del soporte.

## 3. Comparativa

| Recurso | Casa | Clase | Ventaja |
|---|---|---|---|
| Hilos de CPU | 12 | 18 | Clase (+50 %) |
| Generación de CPU | 2017, núcleos iguales | 2023, núcleos híbridos | Clase en potencia; casa en rendimiento **predecible** (todos los núcleos son iguales) |
| RAM | 16 GB | ~32 GB | **Clase (×2)** |
| Disco de las VMs | El mismo SSD por USB a 5 Gb/s | El mismo SSD · puerto N/C | Igual (o mejor en clase si el puerto es de 10 Gb/s) |
| Red física | 1 Gb/s · ~660 Mb/s a Internet · ICMP permitido | Cable del aula · **ICMP a Internet filtrado**, cortes con HTTP/2 | Casa |
| Ampliable | Sí: 2 ranuras de RAM libres, NVMe interno libre para VMs | N/C | Casa |
| VMs a la vez (medido) | ~13 GB disponibles → **no caben las 10** | Cabían las 10 (14,8 GB) y sobraban ~8,9 GB | Clase |

## 4. Cuellos de botella y soluciones

| # | Cuello de botella previsto | Equipo | Solución propuesta |
|---|---|---|---|
| 1 | **RAM**: 16 GB no bastan para el entorno completo | Casa | **a)** Trabajar por escenarios ([00-entorno-pruebas § 8](00-entorno-pruebas.md#8-cuántas-máquinas-se-pueden-arrancar-a-la-vez)). **b)** Ampliar a 32 GB con 2 × 8 GB DDR4-2666 en las ranuras libres A1/B1 (mismo modelo, para no perder el doble canal). **c)** Ajustar la RAM de las VMs que más consumen (TrueNAS y W11). |
| 2 | **Disco**: todas las VMs leen y escriben en un solo SSD por USB a 5 Gb/s | Los dos | **a)** Conectarlo a un puerto de 10 Gb/s si el equipo lo tiene (la caja VL716 lo admite; la Z370-P no). **b)** No arrancar a la vez varias VMs Windows (arranques y actualizaciones con mucha E/S). **c)** En casa, solo si hiciera falta: mover a otro disco los discos de las VMs que no se usan, para liberar espacio y E/S. |
| 3 | **CPU**: el entorno suma 17 vCPU y en casa hay 12 hilos | Casa | Sobreasignar es normal porque casi todas las VMs están en reposo. Para cargas reales: 1 vCPU en las VMs ligeras (routers y nodos vacíos) y no lanzar a la vez instalaciones de Windows. |
| 4 | **CPU híbrida**: VirtualBox puede poner vCPUs en núcleos E (más lentos) | Clase | No se puede medir ahora (N/C). Si se nota lentitud: perfil de energía de máximo rendimiento y menos vCPUs por VM. |
| 5 | **Red**: salida de las VMs | Los dos | No es la red física: es la licencia gratuita del **MikroTik CHR (1 Mb/s)**. Para descargas grandes, usar R2 o R3 como puerta de enlace, o un NAT temporal ([00-entorno-pruebas, problemas 12–13](00-entorno-pruebas.md#9-problemas-encontrados-y-solución)). En clase, probar la conectividad con TCP en vez de ping. |
| 6 | **Firmware distinto en cada equipo** (Secure Boot) | Casa | Pasó al llegar a casa: `vboxdrv` no cargaba porque la clave MOK solo estaba registrada en la placa de clase. Se registró también en la de casa con `mokutil --import`. |
| 7 | **Desgaste** del Kingston A400 (81 %) | Casa | No afecta al proyecto. Vigilar el atributo 231 y no usarlo para VMs ni copias. |

## 5. Tests de diagnóstico (Apte+) · PC de casa

**Condiciones:** 21/11/2026, 21:40–21:46 · 15 min desde el arranque · **ninguna VM encendida** ·
carga inicial 0,45 · 12,1 GB de RAM libres · CPU a 34 °C. Al acabar: carga 1,51 y CPU a 40 °C, así
que no hubo limitación térmica.

| Recurso | Herramienta | Prueba | Resultado | Interpretación |
|---|---|---|---|---|
| Memoria (errores) | memtester 4.6.0 | 1 GB, 1 pasada (10 patrones) | ✅ **Todos los patrones OK** (201 s) | Sin errores en el rango probado. No sustituye a MemTest86+ en el arranque, que revisa toda la RAM. |
| Memoria (ancho de banda) | sysbench 1.0.20 | Escritura en bloques de 1 MiB | 1 hilo: **25.354 MiB/s** · 12 hilos: **114.919 MiB/s** | sysbench mide sobre todo las cachés, así que sirve como referencia para comparar equipos y no como dato absoluto. Escala ×4,5 con 12 hilos: la memoria no frena. El límite es la **cantidad**. |
| CPU | sysbench cpu | Primos hasta 20.000, 15 s | 1 hilo: **577 ev/s** · 12 hilos: **5.375 ev/s** (×9,3) | Escala bien con los 12 hilos (el HyperThreading añade ~55 % sobre los 6 núcleos). |
| Disco externo (secuencial) | fio 3.36, E/S directa, profundidad 16 | Fichero de 1 GB, bloques de 1 MiB | Lectura **430 MiB/s** · escritura **403 MiB/s** | Es el máximo práctico de USB a 5 Gb/s (~450 MB/s). **El límite es el puerto, no el SSD.** |
| Disco externo (aleatorio) | fio | Bloques de 4 KiB | Lectura **20.500 IOPS** (0,7 ms) · escritura **30.200 IOPS** (0,5 ms) | Muy por encima de un disco mecánico (~100–200 IOPS). Bueno para muchas VMs pequeñas. |
| Discos (comparación) | hdparm -t (solo lectura) | Lectura secuencial con búfer | NVMe **2.090 MB/s** · Kingston SATA **241 MB/s** · externo USB **345 MB/s** | El NVMe interno es unas 6 veces más rápido que el disco de las VMs. |
| Red (enlace) | ethtool | Negociación | **1000 Mb/s full duplex**, 0 errores rx/tx | Correcto. |
| Red (latencia local) | ping | 20 paquetes a la puerta de enlace | **0,29 ms** de media, 0 % de pérdidas | LAN de casa sin problemas. |
| Red (latencia a Internet) | ping | 10 paquetes a 1.1.1.1 | **9,8 ms** de media, variación 0,09 ms, 0 % de pérdidas | Conexión estable. |
| Red (DNS) | getent | Resolución de 2 nombres | 30 ms y 43 ms | Normal. |
| Red (caudal) | curl | Descarga de 100 MiB × 3 (proof.ovh.net) | **~82 MB/s ≈ 660 Mb/s** las tres veces | La red física no limita al entorno. |

> Cloudflare rechazó la descarga automatizada (HTTP 403) y la prueba se repitió con el servidor de OVH.
> El script ya usa OVH.

### 5.1 ¿Se confirman los cuellos de botella?

| # | Cuello de botella | ¿Se confirma? | Con qué dato |
|---|---|---|---|
| 1 | RAM de casa | ✅ **Sí** | 16 GB totales y 12,1 GB libres en reposo, frente a los 14,8 GB que ocupa el entorno completo (medido el 19/11). La velocidad es buena: falta cantidad, no rapidez. |
| 2 | Disco externo por USB | ✅ **Sí, es el límite de E/S** | 430/403 MiB/s, justo el techo del USB a 5 Gb/s, frente a 2.090 MB/s del NVMe. Aun así, 20–30 k IOPS bastan para el uso del proyecto. |
| 3 | CPU de casa | ❌ **No** para el uso previsto | Escala ×9,3 con 12 hilos, la temperatura máxima fue de 40 °C y las VMs están casi siempre en reposo. |
| 4 | CPU híbrida de clase | N/C | No se pudo medir en el aula. |
| 5 | Red física | ❌ **No** | 1 Gb/s sin errores, ~660 Mb/s a Internet y 9,8 ms de latencia. El límite real es el CHR (1 Mb/s), que se vio en la Tasca 0. |

## 6. Conclusiones

- El **PC de clase** tiene el doble de RAM y un 50 % más de hilos: allí cabe el entorno completo.
- El **PC de casa** tiene suficiente CPU, disco y red. Su único límite real es la **RAM**, y es el que
  obliga a trabajar por escenarios.
- La mejora más barata y eficaz para casa sería **añadir 2 × 8 GB** en las ranuras libres.
- En los **dos equipos** el disco externo por USB a 5 Gb/s es el techo de E/S. Hoy no molesta, pero
  sería lo primero en notarse si se arrancaran muchas VMs Windows a la vez.
