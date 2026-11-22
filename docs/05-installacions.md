# 05 · Instalaciones y comunicaciones

Tasca 5 «Instal·lació i comunicacions» · RA principales: ISO RA1 d-h y FDM RA1 b-d · **Parte individual**.

> Grupo 3 · Red `192.168.30.0/24` · Instalación: 17 y 19/11/2026 · Pruebas, copias y actualizaciones: 21/11/2026 (PC de casa)
> Diseño de red: [04-disseny.md](04-disseny.md) · Recursos: [05-recursos.md](05-recursos.md) · Credenciales: **fuera del repositorio**

## 1. Qué pedía la Tasca 5 y dónde está

| Lo que se pide | Nivel | Dónde está | Estado |
|---|---|---|---|
| General · Comprobar requisitos y origen de las imágenes y verificar su integridad | Apte | [3.1](#31-origen-e-integridad-de-las-imágenes) | ✅ Hecho |
| General · Actualizar y comprobar el funcionamiento antes de producción | Apte | [3.2](#32-actualización-antes-de-pasar-a-producción) | ✅ Hecho · ⚠️ W11 parcial ([I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md)) |
| General · Problemas, configuraciones críticas y tiempo de respuesta ante una incidencia | Apte | [3.5](#35-problemas-configuraciones-críticas-y-tiempo-de-respuesta) | ✅ Hecho |
| General · Preparar el espacio de copias en TrueNAS y justificar qué se copia, cómo y dónde | Apte | [3.3](#33-espacio-de-copias-en-truenas-qué-cómo-y-dónde) · [D-08](../decisions/D-08-copias-de-configuracion.md) | ✅ Hecho |
| MikroTik · Instalación, versión, usuarios, red WAN y LAN, Internet desde la LAN | Apte | [4.1](#41-instalación) a [4.3](#43-red-wan-y-lan-e-internet-desde-la-lan) | ✅ Hecho |
| MikroTik · Conexión permitida y bloqueada con el registro interpretado | Apte | [4.4](#44-conexión-permitida-y-bloqueada) | ✅ Hecho |
| MikroTik · Copia en el servidor de copias · fallo controlado y recuperación | Apte | [4.5](#45-copia-en-el-servidor-de-copias) · [4.6](#46-fallo-controlado-y-recuperación) | ✅ Hecho |
| OPNsense · Instalación, versión, usuarios, red WAN y LAN, Internet desde la LAN | Apte | [4.1](#41-instalación) a [4.3](#43-red-wan-y-lan-e-internet-desde-la-lan) | ✅ Hecho |
| OPNsense · Conexión permitida y bloqueada · copia · fallo y recuperación | Apte | [4.4](#44-conexión-permitida-y-bloqueada) a [4.6](#46-fallo-controlado-y-recuperación) | ✅ Hecho |
| GNU/Linux con nftables · Instalación, versión, usuarios, red WAN y LAN, Internet desde la LAN | Apte | [4.1](#41-instalación) a [4.3](#43-red-wan-y-lan-e-internet-desde-la-lan) | ✅ Hecho |
| GNU/Linux con nftables · Conexión permitida y bloqueada · copia · fallo y recuperación | Apte | [4.4](#44-conexión-permitida-y-bloqueada) a [4.6](#46-fallo-controlado-y-recuperación) | ✅ Hecho |
| TrueNAS · Versión, usuarios, red y disco adicional para las copias | Apte | [5](#5-nas-truenas) | ✅ Hecho |
| Proxmox · Versión, usuarios, red, clúster y copia (qué se copia y qué no) | Apte | [6](#6-virtualización-proxmox) | ✅ Hecho |
| Proxmox · Migrar una VM y un contenedor y medir tiempo y espacio | Apte | [6.4](#64-migración-de-una-vm-y-un-contenedor) | ⚠️ En el trabajo de grupo: el clúster individual está vacío ([D-04](../decisions/D-04-cluster-anidado-vacio.md)) |
| Windows Server 2025 · Versión, usuarios, red y copia (qué se copia y qué no) | Apte | [7](#7-centralización-windows-server-2025) | ✅ Hecho (reinstalado por [I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md)) |
| Windows Server 2025 · Explicar qué es un dominio y qué aporta | Apte | [7.3](#73-qué-es-un-dominio-y-qué-aporta-a-la-empresa) | ✅ Hecho |
| Servidores GNU/Linux de infraestructura · Instalación, usuarios, red, copia y software | Apte | [9](#9-servidores-gnulinux-de-infraestructura) | ⚠️ En el trabajo de grupo ([D-07](../decisions/D-07-servidores-debian-vm.md)) |
| Cliente Windows 11 · Versión, usuarios, red y copia | Apte | [8.1](#81-windows-11-pro) | ✅ Hecho |
| Cliente GNU/Linux · Versión, usuarios, red y copia | Apte | [8.2](#82-debian-13-con-gnome) | ✅ Hecho |
| Ampliación: automatizar las copias de configuraciones o imágenes | Apte+ | [3.4](#34-copias-automáticas-apto) | ✅ Hecho |

Evidencias de esta tarea: todos los ficheros `t5-*` de [evidencies/](../evidencies/).

## 2. Qué hay instalado

Todo son VMs de VirtualBox en el grupo `/SOX-G3`, en la red interna `LAN_G3` (ver [D-01](../decisions/D-01-wan-por-nat.md) a [D-07](../decisions/D-07-servidores-debian-vm.md)).

| Función | Sistema y versión (21/11/2026) | IP | Usuarios de administración |
|---|---|---|---|
| Comunicaciones (principal) | MikroTik RouterOS **7.25.1** CHR (`R1-MikroTik`) | .1 · WAN 10.0.2.15 | `admin` (de fábrica) y **`admin-g3`** (propio, grupo `full`) |
| Comunicaciones | OPNsense **26.7.9_3** (FreeBSD 15.1-p6) | .2 · WAN 10.0.2.15 | `root` (consola, web y SSH solo por la LAN) |
| Comunicaciones | Debian **13.8** + nftables (`r3-debian`) | .3 · WAN 10.0.2.15 | `asix` (con `sudo`) y `root` (solo consola) |
| NAS y copias | TrueNAS SCALE **25.10.7** (`nas`) | .20 | `truenas_admin` (administración) y `copias` (servicio de copias) |
| Centralización | Windows Server 2025 Standard (escritorio), fuera del clúster · compilación **26100.33438** | .21 | `asix` (administrador local) y `Administrador` |
| Virtualización | Proxmox VE **9.2.32** · clúster `cluster-g3` de 3 nodos, **vacío** | .32 · .33 · .34 | `root@pam` y **`admin-g3@pve`** (grupo `administradores`, rol *Administrator*) |
| Cliente de Dirección | Windows 11 Pro 23H2 (22631.2861, **sin soporte**) | .100 | `asix` (administrador local) y `Administrador` |
| Cliente de Producción | Debian **13.8** + GNOME 48 (`deb-produccion`) | .101 | `asix` (con `sudo`) y `root` |

Todas las IP son manuales (no hay DHCP en la empresa, [D-02](../decisions/D-02-sin-dhcp.md)). Puerta de enlace `.1` y DNS
`172.16.222.1`, el del centro.

## 3. Comprobaciones generales

### 3.1 Origen e integridad de las imágenes

Cada imagen se descargó de la web oficial del fabricante (o del servidor de recursos del centro). Todas son de
**64 bits (amd64/x86_64)**, la arquitectura del i7-8700 y de los nodos virtuales. Los requisitos mínimos de cada
sistema, comparados con lo asignado, están en [05-recursos § 2](05-recursos.md#2-requisitos-mínimos-oficiales-frente-a-lo-asignado).

La integridad se comprueba con la **suma SHA256**: es la huella del fichero. Si coincide con la que publica el
fabricante, la descarga está completa y nadie la ha modificado. Las sumas publicadas se bajaron el mismo día de
la web oficial ([t5-sha256-imagenes](../evidencies/t5-sha256-imagenes-20261121.txt)).

| Imagen | Origen | SHA256 calculada | ¿Coincide con la publicada? |
|---|---|---|---|
| `chr-7.24.5.vdi` (R1) | download.mikrotik.com | `c102a4ab…bf36370` | ✅ Sí, a través del ZIP oficial: el ZIP coincide (`c5e33cbc…`) y el VDI de dentro es idéntico |
| `debian-13.1.0-amd64-netinst.iso` (R3, cliente) | cdimage.debian.org | `658b28e2…c65568b3` | ✅ Sí (`SHA256SUMS` de Debian) |
| `proxmox-ve_9.2-1.iso` | enterprise.proxmox.com | `4e88fe41…73ef2c6c` | ✅ Sí (`SHA256SUMS` de Proxmox) |
| `TrueNAS-SCALE-25.10.7.iso` | download.sys.truenas.net | `54ce9441…7a007c8e` | ✅ Sí (fichero `.sha256` oficial) |
| `mikrotik-7.24.5.iso` (no se usó) | download.mikrotik.com | `4bff16b8…aaec02` | ✅ Sí |
| `w2k25.iso`, `w11.iso` | Microsoft (evaluación y descarga de Windows 11) | `b73c9688…`, `5210deed…` | Microsoft no publica la suma de estas descargas: queda anotada |
| `opnsense.vdi` | Servidor de recursos del centro | `dd452761…` | Sin suma publicada: queda anotada. Era una imagen *live* (problema 2 del [apartado 10](#10-problemas-encontrados-y-solución)) |

### 3.2 Actualización antes de pasar a producción

Antes de dar un sistema por terminado se actualiza y se comprueba que sigue funcionando
([t5-actualizaciones](../evidencies/t5-actualizaciones-20261121.txt),
[t5-proxmox-actualizacion-usuarios-copias](../evidencies/t5-proxmox-actualizacion-usuarios-copias-20261121.txt)).

| Sistema | Antes | Después | Paquetes | Comprobación después |
|---|---|---|---|---|
| R1 MikroTik | 7.24.5 | **7.25.1** | Paquete de sistema | Copia previa en el NAS. Reinicio en 11 s; NAT, rutas y reglas siguen igual |
| R2 OPNsense | 26.7 (FreeBSD 15.1-p1) | **26.7.9_3** (15.1-p6) | 98 + base y kernel | SSH, NAT y reglas. Tuvo un problema de PAM hasta reiniciar ([I-07](../incidencies/I-07-opnsense-ssh-tras-actualizar.md)) |
| R3 Debian | 13.7 | **13.8** | 20 (glibc, OpenSSL, sudo, GRUB…) | nftables activo, NAT desde el cliente |
| Cliente Debian | 13.7 | **13.8** | 30 | Inicio de sesión gráfico y red |
| Proxmox (×3) | 9.2.2 · kernel 7.0.2 | **9.2.32** · kernel **7.0.14** | 224 por nodo | **De uno en uno**: el clúster nunca baja de 2 votos. Cada nodo vuelve con 3 votos en ~60 s |
| TrueNAS | 25.10.7 | **25.10.7** (no se actualiza) | — | Ver abajo |
| Windows Server 2025 | 26100.1742 | **26100.33438** | 4 (acumulativa 2026-09 y Defender) | IP, puerta de enlace y DNS iguales después de reiniciar |
| Windows 11 Pro | 22631.2861 (23H2) | 22631.2861 · **parcial** | 4 de 5 (falla la acumulativa, [I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md)) | Red y carpeta del NAS iguales; **la 23H2 ya no tiene soporte**: hay que subirlo de versión |

- **TrueNAS no se actualiza a propósito.** La versión 25.10.8 (03/11/2026, 2 GB) ya existe, pero el perfil de
  actualización del NAS, *Mission Critical*, todavía no la recomienda (`new_version: null`). En un servidor de copias se
  prefiere esperar. Además, por R1 la descarga iría a 1 Mbit/s ([I-03](../incidencies/I-03-descargas-lentas-por-r1.md)).
- **En casa no hay DNS del centro** ([I-04](../incidencies/I-04-dns-fuera-del-aula.md)). Para actualizar se usó
  `10.0.2.3`, el DNS del NAT de VirtualBox, y R3 como puerta de enlace (no tiene el límite de 1 Mbit/s de R1). Al acabar
  se volvió a lo de siempre. Nuestra propia regla de DNS bloqueaba esa consulta: ver [I-08](../incidencies/I-08-regla-dns-bloquea-actualizaciones.md).

### 3.3 Espacio de copias en TrueNAS: qué, cómo y dónde

**Dónde.** En el pool `copias` (disco de 20 GB **distinto** del disco de sistema del NAS: si hubiera que reinstalar
TrueNAS, las copias no se pierden). Dos datasets con cuota, para que una copia grande no llene el pool:

| Dataset | Cuota | Cómo se llega | Qué guarda |
|---|---|---|---|
| `copias/configuraciones` | 4 GB | **NFS** (Linux y Proxmox, solo desde `192.168.30.0/24`) · **SFTP** (MikroTik y OPNsense) · **SMB** `\\192.168.30.20\configuraciones` (Windows) | Una carpeta por equipo con su configuración |
| `copias/imagenes` | 14 GB | SFTP/SCP | Imagen completa (OVA) de la VM más pequeña y crítica, R1 |

Todo entra con el usuario de servicio `copias` (uid 3000, permisos `770`): ni los equipos ni los usuarios
escriben como administrador del NAS. Sobre el pool hay **instantáneas** diarias (03:00) que se guardan 2 semanas: si
se borra o se estropea una copia, se puede volver a la del día anterior.

**Qué se copia de cada equipo** ([D-08](../decisions/D-08-copias-de-configuracion.md)):

| Equipo | Tipo | Qué es exactamente | Tamaño |
|---|---|---|---|
| R1 MikroTik | Configuración + imagen | `.backup` (binario, restaura todo) y `.rsc` (exportación en texto, legible) · OVA de la VM completa | 22 KB + 2,5 KB · 63 MB |
| R2 OPNsense | Configuración | `/conf/config.xml`: todo OPNsense está en ese fichero | 42 KB |
| R3 Debian | Configuración | `.tar.gz` de `/etc` (red, nftables, sysctl, SSH, apt, systemd) + lista de paquetes + SHA256 | 64 KB |
| TrueNAS | Configuración | Base de datos de configuración (`config/save`), en el pool y **fuera del NAS** (en el anfitrión) | 816 KB |
| Proxmox (×3) | Configuración | `.tar.gz` de `/etc/pve` (clúster, usuarios, almacenamiento), `/etc/corosync`, red y apt de cada nodo | 81 KB por nodo |
| Windows Server | Configuración | Red, cortafuegos, directivas de seguridad, usuarios, roles y parches (texto, `.reg`, `.wfw`, `.inf`) por SMB | 211 KB |
| Windows 11 | Configuración | Lo mismo que el servidor + lista de aplicaciones y datos del equipo | 336 KB |
| Cliente Debian | Configuración | Igual que R3 (incluye los perfiles de NetworkManager) | 65 KB |

**Qué no se copia, y por qué:**

- **Imágenes completas** de las VMs grandes. Sus discos suman unos 65 GB (W11 14 GB, WS2025 14 GB…) y el pool tiene 20:
  no caben. Se recuperan reinstalando desde la ISO (unos 10–35 min) y restaurando después la configuración. La
  excepción es R1, cuya imagen ocupa 63 MB.
- **Las ISO**: se vuelven a descargar, y su SHA256 está anotado en el apartado 3.1.
- **Claves privadas**: `/etc/pve/priv`, `*.key` y las claves de host SSH. No deben estar en una carpeta de red y se
  regeneran (`pvecm updatecerts`, `ssh-keygen -A`).
- **Datos de usuarios**: por ahora no hay. En la empresa irían en una carpeta del NAS, no en los clientes.

**Espacio.** Una copia de configuración de todos los equipos ocupa unos **2 MB**; la carpeta entera, con las copias
repetidas de las pruebas, ocupa 2,4 MB. Con 7 copias por equipo (la rotación del script) serían unos 15 MB, el 0,4 % de
la cuota de 4 GB. La imagen de R1 ocupa 63 MB de los 14 GB de `imagenes`. Las instantáneas solo guardan lo que cambia. Hay margen para
años de configuraciones o para unas cuantas imágenes pequeñas más ([t5-copias-nas](../evidencies/t5-copias-nas-20261121.txt)).

### 3.4 Copias automáticas (Apto+)

| Equipo | Cómo | Cuándo | Comprobado |
|---|---|---|---|
| R1 MikroTik | `/system script copia-nas` + `/system scheduler`: `backup save`, `export` y subida por SFTP | Cada día a las 02:00 | ✅ Ejecutado a mano: `copia-nas: R1-2026-11-21 subida al NAS` en el registro |
| R3, cliente Debian y los 3 nodos Proxmox | [`scripts/copia-config.sh`](../scripts/copia-config.sh) + [`copia-config.timer`](../scripts/copia-config.timer) de systemd: monta el NFS, hace el `.tar.gz` con su SHA256, guarda las 7 últimas y desmonta | Cada día a las 02:30 (± 15 min, `Persistent=true`: si el equipo estaba apagado, la hace al encender) | ✅ `systemctl start copia-config.service` en los 5 equipos |
| TrueNAS | Tarea de instantáneas del pool `copias` | Cada día a las 03:00, se guardan 2 semanas | ✅ Tarea creada + instantánea manual `manual-tasca5-20261121` |

Así, cada noche R1 y los equipos Linux copian su configuración, y una hora después el NAS congela el estado de todas
las copias. El script es el mismo para todos los equipos Linux: el nombre de la carpeta es el `hostname` y solo se
copian las rutas que existen en cada uno.

### 3.5 Problemas, configuraciones críticas y tiempo de respuesta

**Tiempo de respuesta medido ante cada incidencia** (detalle en el [apartado 4.6](#46-fallo-controlado-y-recuperación) y en [incidencies/](../incidencies/)):

| Incidencia | Detección | Recuperación | Sin servicio |
|---|---|---|---|
| R3 sin `nftables.conf` ni reenvío, tras reiniciar | Inmediata (el cliente pierde Internet) | **1 s** de órdenes desde la copia del NAS | 42 s, contando el reinicio |
| R1 sin NAT ni ruta por defecto | Inmediata | **17 s** (descarga del `.backup` + carga + reinicio) | 24 s |
| OPNsense con la IP de la LAN equivocada | Al caducar la caché ARP del cliente (ver 4.6) | **57 s** por la consola | 82 s |
| WS2025 no arranca y se reinstala solo ([I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md)) | Al encenderlo (23:19) | **8 min** de reinstalación desatendida + 4 min de copia de la configuración | ~11 min hasta el escritorio |
| Reinicio de un nodo Proxmox tras actualizar | — | — | ~60 s hasta volver al clúster con 3 votos |

**Configuraciones críticas detectadas:**

| Riesgo | Por qué es crítico | Estado |
|---|---|---|
| **Disco raíz de los nodos Proxmox al 83 %** (al 94 % justo después de actualizar) | Solo 6,9 GB de sistema; con otro kernel nuevo se puede llenar y fallar la siguiente actualización | Liberados 652 MB de caché de apt por nodo. Para el futuro: `apt autoremove` de los kernels viejos |
| **R1 es la única salida de la LAN** y tiene un límite de 1 Mbit/s | Si cae R1, todos los equipos se quedan sin Internet hasta cambiarles la puerta de enlace | Hay dos routers alternativos (R2, R3) y R1 se recupera en 17 s |
| **Las copias están en el mismo disco externo** que todo el entorno | Protegen de errores de configuración, no de que se rompa el disco | Aceptado en el entorno de pruebas ([D-08](../decisions/D-08-copias-de-configuracion.md)); la configuración del NAS se guarda también en el anfitrión |
| **El dataset de sistema de TrueNAS** se ha movido al pool `copias` (lo hace TrueNAS solo) | Registros y configuración de servicios del NAS comparten disco con las copias | Aceptado: el disco de sistema es pequeño |
| **La contraseña del usuario `copias` está en el script de MikroTik** | Quien lea la configuración de R1 la ve | `copias` solo puede escribir en sus datasets. No se exporta al repositorio sin quitarla |
| **Apagar el PC con VMs de Windows cerrándose** | Dejó WS2025 sin arranque ([I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md)) | Medios de instalación quitados y apagado ordenado de las VMs |
| **W11 en una versión sin soporte** (23H2) y sin la última acumulativa | El cliente de Dirección no recibe parches de seguridad | Sin resolver: actualización de características pendiente ([I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md)) |
| **WS2025 es una versión de evaluación** (180 días) | Pasado el plazo se apaga cada hora | Suficiente para el proyecto; en producción, activar con clave |
| **OPNsense está en UTC** y el resto en hora de Madrid | Al comparar registros de varios equipos hay que sumar 1 h a OPNsense | Anotado en las evidencias |

## 4. Comunicaciones: MikroTik, OPNsense y Debian con nftables

Los equipos de la empresa necesitan **salir a Internet de forma controlada**. Hay tres routers sobre la misma LAN,
con la misma función, para compararlos: R1 es la puerta de enlace de todos, y R2 y R3 son alternativas que se
pueden usar cambiando la ruta.

### 4.1 Instalación

Todas están en el grupo `/SOX-G3` de VirtualBox, con dos adaptadores: NAT (WAN) e `intnet LAN_G3` (LAN). Ejemplo con MikroTik:

```bash
VBoxManage createvm --name R1-MikroTik-CHR --ostype Linux26_64 --groups /SOX-G3 --register
VBoxManage clonemedium disk chr-7.24.5.vdi "~/VirtualBox VMs/SOX-G3/R1-MikroTik-CHR/R1-MikroTik-CHR.vdi"
VBoxManage modifyvm R1-MikroTik-CHR --memory 256 --cpus 1 \
  --nic1 nat --nic2 intnet --intnet2 LAN_G3 \
  --natpf1 "ssh,tcp,127.0.0.1,2201,,22" --natpf1 "winbox,tcp,127.0.0.1,8291,,8291"
```

| Router | Instalación | Decisiones |
|---|---|---|
| R1 MikroTik | Imagen oficial **CHR** (VDI) | La ISO x86 sin licencia es una demo de 24 h; la CHR es gratuita y sin caducidad, con un límite de 1 Mbit/s por interfaz ([D-03](../decisions/D-03-mikrotik-chr.md)) |
| R2 OPNsense | Instalador *live* en un disco nuevo de 10 GB, con **UFS** | ZFS necesita más RAM. Se instaló con 3 GB (el instalador los pide) y después se bajó a 1 GB |
| R3 Debian | `VBoxManage unattended install` desde la netinst, **sin entorno gráfico**, con `openssh-server` y `nftables` (+ `sudo`, `tcpdump`, `curl`, `rsync`, `nfs-common`) | Solo lo necesario para enrutar y filtrar |

### 4.2 Usuarios de administración

| Router | Usuarios | Cómo se configuró |
|---|---|---|
| R1 | `admin` (de fábrica, con contraseña nueva) y **`admin-g3`** (grupo `full`) | `/user set admin password=…` · `/user add name=admin-g3 group=full` · comprobado entrando por SSH con `admin-g3` |
| R2 | `root` | Contraseña cambiada en la instalación. SSH activado **solo en la interfaz LAN** (escucha en `192.168.30.2:22`); por la WAN, el cortafuegos lo bloquea |
| R3 | `asix` (en el grupo `sudo`) y `root` | Debian no deja entrar como `root` por SSH: se administra con `asix` + `sudo` |

Las contraseñas están fuera del repositorio, como pide el enunciado.

### 4.3 Red WAN y LAN, e Internet desde la LAN

| | R1 MikroTik | R2 OPNsense | R3 Debian |
|---|---|---|---|
| WAN | `ether1-WAN` 10.0.2.15/24, gw 10.0.2.2 | `em0` 10.0.2.15/24, gw 10.0.2.2 | `enp0s3` 10.0.2.15/24, gw 10.0.2.2 |
| LAN | `ether2-LAN` 192.168.30.1/24 | `em1` 192.168.30.2/24 | `enp0s8` 192.168.30.3/24 |
| NAT | `srcnat masquerade` por `ether1-WAN` | NAT de salida automático | `masquerade` en `nftables.conf` |
| Reenvío | Por defecto | Por defecto | `net.ipv4.ip_forward = 1` en `/etc/sysctl.d/99-enrutador.conf` |
| DNS | `172.16.222.1` | `172.16.222.1` (Unbound) | `172.16.222.1` |
| Servidor DHCP | Ninguno | Ninguno (desactivado en la LAN) | Ninguno |

Configuración de R1 ([`configs/R1-MikroTik/`](../configs/R1-MikroTik/)):

```routeros
/system identity set name=R1-MikroTik
/interface ethernet set [find default-name=ether1] name=ether1-WAN
/interface ethernet set [find default-name=ether2] name=ether2-LAN
/ip address add address=10.0.2.15/24 interface=ether1-WAN comment="WAN - VirtualBox NAT"
/ip address add address=192.168.30.1/24 interface=ether2-LAN comment="LAN G3"
/ip route add dst-address=0.0.0.0/0 gateway=10.0.2.2
/ip dns set servers=172.16.222.1 allow-remote-requests=no
/ip firewall nat add chain=srcnat out-interface=ether1-WAN action=masquerade comment="NAT LAN -> WAN"
```

En OPNsense, las interfaces se asignaron desde la consola: opción 1 (`WAN → em0`, `LAN → em1`, comprobado por la MAC)
y opción 2 (IP de cada una, sin DHCP ni IPv6). El cortafuegos de R3 está en
[`configs/R3-Debian-nftables/nftables.conf`](../configs/R3-Debian-nftables/nftables.conf): `input` y `forward` con
política `drop`, solo se deja pasar LAN → WAN y sus respuestas, y `masquerade` al salir por la WAN.

**Verificación** (17/11 en el aula y 21/11 en casa):

| Prueba | R1 | R2 | R3 |
|---|---|---|---|
| IP WAN y LAN, ruta por defecto vía 10.0.2.2 | ✅ | ✅ | ✅ |
| `ping 172.16.222.1` y resolución DNS (en el aula) | ✅ | ✅ | ✅ |
| **Un cliente de la LAN sale a Internet** a través del router (`HTTP/1.1 301` de 1.1.1.1) | ✅ | ✅ | ✅ |
| Ningún servidor DHCP | ✅ `/ip dhcp-server` vacío | ✅ nada en el puerto 67 | ✅ nada en el puerto 67 |

Evidencias: [R1](../evidencies/t5-mikrotik-verificacion-ip-ruta-ping-dns-20261117.png) ·
[R2 interfaces](../evidencies/t5-opnsense-asignacion-interfaces-20261117.png) ·
[R2 IPs](../evidencies/t5-opnsense-consola-ips-20261117.png) ·
[R2 ping y DNS](../evidencies/t5-opnsense-verificacion-ping-dns-20261117.png) ·
[R3](../evidencies/t5-debian-nftables-verificacion-20261117.txt) ·
[cliente por cada router](../evidencies/t5-routers-permitida-bloqueada-20261121.txt).

### 4.4 Conexión permitida y bloqueada

Se aplicó **la misma política en los tres** para poder compararlos:

- **Bloqueada:** el DNS (TCP/UDP 53) desde la LAN hacia cualquier servidor que **no** sea el de la empresa (`172.16.222.1`).
  Así nadie se salta el DNS de la empresa usando, por ejemplo, `8.8.8.8`.
- **Permitida y registrada:** el HTTP (TCP 80) desde la LAN hacia Internet.

La prueba se hizo desde el cliente Debian (`.101`), usando cada router como puerta de enlace con una ruta temporal, y
**antes y después** de poner las reglas ([t5-routers-permitida-bloqueada](../evidencies/t5-routers-permitida-bloqueada-20261121.txt)):

| Router | Regla añadida | HTTP a 1.1.1.1 antes → después | DNS a 8.8.8.8 antes → después |
|---|---|---|---|
| R1 | `/ip firewall filter add chain=forward in-interface=ether2-LAN dst-address=!172.16.222.1 protocol=tcp dst-port=53 action=drop log=yes log-prefix="R1-BLOQ-DNS-EXT"` (y otra igual con `udp`) + `accept` del puerto 80 con `log-prefix="R1-PERMITE-HTTP"` | ✅ → ✅ | ✅ conecta → ❌ descartado |
| R2 | En el modelo de reglas de OPNsense: *block* TCP/UDP destino `!172.16.222.1` puerto 53 y *pass* TCP 80, las dos con *log*, delante de *Default allow LAN to any* | ✅ → ✅ | ✅ conecta → ❌ descartado |
| R3 | En `forward`: `iifname $LAN ip daddr != $DNS_EMPRESA meta l4proto { tcp, udp } th dport 53 log prefix "R3-BLOQ-DNS-EXT " drop` + `tcp dport 80 ct state new log prefix "R3-PERMITE-HTTP " accept` | ✅ → ✅ | ✅ conecta → ❌ descartado |

**Interpretación del registro.** Una línea de cada router (MAC ocultadas):

```text
R3  kernel: R3-BLOQ-DNS-EXT IN=enp0s8 OUT=enp0s3 SRC=192.168.30.101 DST=8.8.8.8 PROTO=TCP SPT=40120 DPT=53 SYN
R1  firewall,info R1-BLOQ-DNS-EXT forward: in:ether2-LAN out:ether1-WAN, connection-state:new, proto TCP (SYN),
    192.168.30.101:48968->8.8.8.8:53
R2  filterlog: 69,,,a84b8eb1-…,em1,match,block,in,4,…,tcp,60,192.168.30.101,8.8.8.8,56994,53,0,S,…
```

- **Quién y hacia dónde:** el cliente `192.168.30.101` intenta conectar con `8.8.8.8`, puerto **53** (DNS), y el paquete
  entra por la interfaz **LAN** del router (`enp0s8`, `ether2-LAN`, `em1`).
- **Qué paquete:** un **SYN**, es decir, el primer paquete de una conexión TCP nueva (`connection-state:new`).
- **Qué se hizo:** lo indica el prefijo (`BLOQ-DNS-EXT`) o, en OPNsense, los campos `match,block,in` y el
  identificador (`a84b8eb1-…`) de la regla que coincidió. Para saber qué regla es, se busca ese identificador en `pfctl -sr`.
- **Por qué hay 4 líneas seguidas, una por segundo:** como el router descarta el paquete sin responder, el cliente
  reintenta el SYN (en 1, 2 y 3 s) hasta que se rinde. Si la regla fuera `reject`, el cliente lo sabría al momento.
- **La línea `PERMITE-HTTP`** sale **una sola vez** por conexión: la regla solo mira `connection-state:new`, y los demás
  paquetes de esa conexión pasan por la regla de *established* sin registrarse. Así el registro no se llena.
- R1 registró además un `RST` con `connection-state:invalid`. Era el cierre de una conexión DNS que se había abierto
  **antes** de poner la regla: el router no la tenía como establecida y la descartó igualmente.

**Diferencias entre los tres:** en MikroTik no se filtra nada hasta que se añaden reglas. OPNsense bloquea por defecto
todo lo que entra por la WAN y deja salir todo desde la LAN, y además tiene dos sitios para las reglas, el modelo
clásico y el nuevo, que se aplican en orden distinto ([I-06](../incidencies/I-06-opnsense-orden-reglas.md)). En Debian
solo pasa lo que está escrito en `nftables.conf`.

### 4.5 Copia en el servidor de copias

| Router | Cómo | Dónde (en el NAS) |
|---|---|---|
| R1 | `/system backup save` + `/export show-sensitive` + `/tool fetch upload=yes mode=sftp` (script `copia-nas`, también programado) | `configuraciones/r1-mikrotik/R1-2026-11-21.backup` y `.rsc` · imagen `imagenes/R1-MikroTik-CHR-20261121.ova` (+ SHA256, comprobada en el NAS) |
| R2 | `scp /conf/config.xml copias@192.168.30.20:…` desde el propio OPNsense | `configuraciones/r2-opnsense/config-20261121-2145.xml` y `-2148.xml` (después de añadir las reglas) |
| R3 | `copia-config.sh` por NFS (también programado) | `configuraciones/r3-debian/config-20261121-HHMM.tar.gz` + `.sha256` + `paquetes-…txt` |

La copia se repitió **después** de añadir las reglas de 4.4, para que la recuperación las incluyera.

### 4.6 Fallo controlado y recuperación

En cada router se simuló un error de administración diferente y se recuperó **solo con la copia del NAS**
([t5-routers-fallo-recuperacion](../evidencies/t5-routers-fallo-recuperacion-20261121.txt)):

| Router | Fallo provocado | Qué se vio | Recuperación | Tiempo |
|---|---|---|---|---|
| R3 | Se borran `/etc/nftables.conf` y `/etc/sysctl.d/99-enrutador.conf` y se reinicia | `nftables` *failed*, **0 reglas** (el router queda abierto) y sin reenvío: el cliente no sale | Montar el NFS, comprobar el SHA256 de la última copia, extraer solo esos dos ficheros, `sysctl -p` y `systemctl restart nftables` | **1 s** de órdenes · 42 s sin servicio |
| R1 | Se borran la regla de NAT y la ruta por defecto | El cliente no sale (`SIN RESPUESTA`) | `/tool fetch mode=sftp` del `.backup` desde el NAS y `/system backup load` (reinicia solo) | **17 s** hasta tener ruta otra vez · 24 s sin servicio |
| R2 | Se cambia en `config.xml` la IP de la LAN a `.222` y se aplica | `ping .2` falla, **pero el cliente sigue saliendo** hasta que caduca su caché ARP; después, sin salida. El SSH también se pierde | Desde la **consola**: `scp` del `config.xml` desde el NAS (la `.222` está en la misma red y llega), copiarlo a `/conf/config.xml`, `configctl interface reconfigure lan` y `filter reload` | **57 s** en consola · 82 s sin servicio |

En las tres recuperaciones, la prueba final desde el cliente da `HTTP 301` permitido y DNS externo bloqueado: se
recupera la configuración **con** las reglas de 4.4. Capturas de la recuperación de R2:
[descarga de la copia](../evidencies/t5-opnsense-recuperacion-consola-descarga-copia-20261121.png) ·
[configuración restaurada](../evidencies/t5-opnsense-recuperacion-consola-restaurada-20261121.png).

> Lo que enseña el fallo de R2: un cambio de IP del router **no se nota al momento**, porque los clientes siguen
> enviando a la MAC que tienen en la caché ARP y el router reenvía todo lo que le llega a su MAC. El fallo aparece
> minutos después, y eso lo hace más difícil de relacionar con el cambio.

### 4.7 Comparación de los tres

| | MikroTik CHR | OPNsense | Debian + nftables |
|---|---|---|---|
| RAM en uso | ~200 MB de 256 MB (`/system resource print`) | 1 GB asignado; no medido (Tasca 7) | ~106 MB de 512 MB (`free -m`) |
| Filtrado por defecto | Nada | WAN bloqueada, LAN permitida | Lo que se escribe (`drop` por defecto) |
| Copia de la configuración | `.backup` + `.rsc`, con programador propio | Un solo `config.xml` | Ficheros de `/etc` |
| Recuperación | La más rápida (`backup load`) | Necesita consola si se pierde la LAN | Muy rápida, pero hay que saber qué ficheros restaurar |
| Lo peor | Límite de 1 Mbit/s de la licencia *free* | Dos modelos de reglas ([I-06](../incidencies/I-06-opnsense-orden-reglas.md)) | Todo a mano: un error deja el router abierto (visto en 4.6) |

## 5. NAS: TrueNAS

| Qué se pide | Cómo está |
|---|---|
| Versión y funcionamiento | TrueNAS SCALE 25.10.7 (tren *Goldeye*), 2 vCPU, 3 GB de RAM. Pool `copias` **ONLINE** ([t5-truenas-estado](../evidencies/t5-truenas-estado-20261119.txt), [t5-copias-nas](../evidencies/t5-copias-nas-20261121.txt)) |
| Usuarios de administración | `truenas_admin` (administrador; el instalador desactiva el acceso de `root` por contraseña) y `copias` (servicio: solo sus datasets, SMB y SFTP) |
| Red | `enp0s3` 192.168.30.20/24, puerta de enlace .1, DNS 172.16.222.1, nombre `nas.grupo3.lan` |
| Disco adicional para las copias | Disco de 20 GB aparte del de sistema (16 GB), con el pool `copias` (stripe de un disco) y los datasets del apartado 3.3 |
| Servicios | NFS (solo `192.168.30.0/24`), SMB y SSH/SFTP con contraseña, activados al arrancar |

La configuración se instaló con la API REST de TrueNAS (`/api/v2.0/…`) desde el anfitrión, por un túnel SSH a través
de R3: crear el usuario, los datasets con cuota, los permisos, los recursos compartidos, los servicios y la tarea de
instantáneas.

## 6. Virtualización: Proxmox

### 6.1 Instalación, usuarios y red

| Qué se pide | Cómo está |
|---|---|
| Versión y funcionamiento | Proxmox VE 9.2.32, kernel 7.0.14, en 3 VMs de VirtualBox con virtualización anidada (2 vCPU y 1,5 GB cada una) |
| Usuarios de administración | `root@pam` (solo para lo imprescindible) y **`admin-g3@pve`**, en el grupo `administradores` con el rol *Administrator* en `/`. Comprobado pidiendo un ticket de acceso con `pvesh create /access/ticket` |
| Red | Cada nodo: puente `vmbr0` sobre la tarjeta de `LAN_G3`, IP fija .32/.33/.34, puerta de enlace .1, DNS 172.16.222.1 |
| Repositorios | `pve-no-subscription` activado y `enterprise` desactivado (sin suscripción) |
| Almacenamiento | `local` (sistema), `local-lvm` y **`nas-copias`** (NFS del NAS, para copias `vzdump` cuando haya VMs, con `keep-last=3`) |

### 6.2 Clúster

`cluster-g3` con pve1, pve2 y pve3: 3 votos, quórum con 2. La prueba de quórum (3 → 2 → 1 nodo, y vuelta) está en
[t5-proxmox-prueba-quorum](../evidencies/t5-proxmox-prueba-quorum-20261119.txt). Tras la actualización del 21/11, los tres
nodos volvieron al clúster con 3 votos ([t5-proxmox-actualizacion-usuarios-copias](../evidencies/t5-proxmox-actualizacion-usuarios-copias-20261121.txt)).

### 6.3 Copia: qué se copia y qué no

- **Se copia** (cada día, `copia-config.sh`): `/etc/pve` (configuración del clúster, usuarios, permisos y
  almacenamientos; es la misma en los tres nodos, porque el clúster la replica), `/etc/corosync`, `/etc/network`,
  `/etc/hosts` y `/etc/apt` de **cada** nodo, más la lista de paquetes. Unos 81 KB por nodo.
- **No se copia:** las claves privadas (`/etc/pve/priv`, `*.key`) porque no deben estar en una carpeta de red y se
  regeneran; el sistema operativo, porque reinstalar desde la ISO es más rápido que restaurar una imagen; y **ninguna
  VM**, porque el clúster individual está vacío ([D-04](../decisions/D-04-cluster-anidado-vacio.md)). Cuando haya VMs,
  irán con `vzdump` al almacenamiento `nas-copias`, que ya está creado.

> Al revisar la primera copia se vio que llevaba `etc/pve/priv/`: se añadieron las exclusiones al script y se borraron
> esas copias del NAS antes de seguir.

### 6.4 Migración de una VM y un contenedor

El clúster individual está **vacío por decisión** ([D-04](../decisions/D-04-cluster-anidado-vacio.md)): solo simula la
estructura de la empresa, y las VMs y contenedores se montan en el trabajo de grupo. La migración, con sus tiempos y
espacio, está hecha y medida allí (Tasca 5 del grupo, apartado 6:
[repositorio del grupo](https://github.com/varo010/asix-aula-grup-03-ISO)).

## 7. Centralización: Windows Server 2025

### 7.1 Instalación, usuarios y red

Fuera del clúster, en su propia VM de VirtualBox ([D-05](../decisions/D-05-ws2025-fuera-del-cluster.md)).

| Qué se pide | Cómo está |
|---|---|
| Versión y funcionamiento | Windows Server 2025 Standard con experiencia de escritorio, 2 vCPU, 2 GB, 40 GB, EFI + TPM 2.0. Instalación desatendida (`VBoxManage unattended install`). **Reinstalado el 21/11** por la incidencia [I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md): de 23:21:57 a 23:30, unos 8 min hasta el escritorio |
| Actualización | Compilación **26100.1742 → 26100.33438**: actualización de seguridad 2026-09 (KB5122871 y KB5122870), plataforma de Windows Security, inteligencia de Defender y herramienta de eliminación de software malintencionado. Descarga en 19 min 38 s, instalación en 20 min 29 s y reinicio en ~7 min ([captura](../evidencies/t5-ws2025-actualizacion-20261122.png), [versión después](../evidencies/t5-ws2025-version-tras-actualizar-20261122.png)) |
| Licencia | Versión de **evaluación** (*Standard Evaluation*): válida 180 días. Basta para el proyecto; en producción se activaría con una clave |
| Usuarios de administración | `asix` (administrador local, creado por la instalación) y `Administrador` (integrado), los dos con contraseña. Cuando se cree el dominio pasarán a ser cuentas del dominio |
| Red | `Ethernet` 192.168.30.21/24, puerta de enlace .1, DNS 172.16.222.1, puesta por `VBOXPOST.CMD` al acabar la instalación (`netsh interface ipv4 set address … static`). Regla para responder al ping. Comprobado después de reinstalar ([captura](../evidencies/t5-ws2025-red-tras-reinstalar-20261121.png)) |
| Rol de dominio | Aún no: el dominio `grupo3.lan` se monta en el trabajo de grupo. Aquí se explica en el apartado 7.3 |

### 7.2 Copia: qué se copia y qué no

Por SMB, en `\\192.168.30.20\configuraciones\ws2025\20261121\`, con el usuario `copias` y desde una consola de administrador
([captura](../evidencies/t5-ws2025-copia-configuracion-nas-20261121.png)):

| Fichero | Orden | Para qué sirve al recuperar |
|---|---|---|
| `ipconfig.txt`, `red.txt`, `tcpip.reg` | `ipconfig /all`, `netsh interface ipv4 show config`, `reg export …\Tcpip\Parameters` | Volver a poner la misma IP, puerta de enlace, DNS y nombre |
| `cortafuegos.wfw` | `netsh advfirewall export` | Restaurar las reglas con `netsh advfirewall import` |
| `directivas-seguridad.inf` | `secedit /export /cfg` | Directivas locales de contraseñas, auditoría y derechos (`secedit /configure`) |
| `usuarios.txt` | `net user` y `net localgroup Administradores` | Saber qué cuentas hay que volver a crear |
| `roles.txt`, `actualizaciones.txt`, `systeminfo.txt` | `Get-WindowsFeature`, `Get-HotFix`, `systeminfo` | Saber qué roles y qué parches tenía |

Son 9 ficheros y 211 KB. La copia se hizo antes de actualizar: la lista de parches que contiene es la de la instalación. **No se copia:**

- La **imagen completa**: el disco ocupa 14 GB y no cabe con margen en el pool ([D-08](../decisions/D-08-copias-de-configuracion.md)). Reinstalar
  ha costado 8 min (medido en I-09), y después se aplica la configuración copiada.
- El **estado del sistema** (`wbadmin start systemstatebackup`): la característica *Copias de seguridad de Windows Server* no
  está instalada (lo dice la propia consola `wbadmin.msc`). Cuando el servidor sea controlador de dominio, sí habrá que
  copiar el estado del sistema, porque contiene la base de datos de Active Directory, y se instalará la característica.
- Las **contraseñas**: no salen de las cuentas (no se exportan hashes) y están custodiadas fuera del repositorio.

### 7.3 Qué es un dominio y qué aporta a la empresa

Un **dominio** (Active Directory) es una base de datos central, en uno o varios servidores (los *controladores de
dominio*), con todos los usuarios, equipos y grupos de la empresa y las reglas que se les aplican. Los equipos que se
**unen** al dominio dejan de usar solo sus cuentas locales y preguntan al servidor quién es cada usuario y qué puede hacer.

Lo que aporta a la empresa del grupo:

| Sin dominio | Con dominio |
|---|---|
| Cada trabajador tiene un usuario **en cada equipo**; si cambia de puesto, hay que crearlo otra vez | **Un solo usuario** para entrar en cualquier equipo de la empresa |
| Cambiar una contraseña o dar de baja a alguien obliga a ir equipo por equipo | Se cambia o se desactiva **una vez** en el servidor y vale para todos |
| Cada equipo se configura a mano (fondo, actualizaciones, unidades de red, seguridad) | **Directivas de grupo (GPO)**: se aplican a la vez a todos los equipos de un departamento |
| Los permisos de las carpetas compartidas se ponen usuario a usuario | Permisos por **grupos** (Dirección, Producción…) |
| No hay registro central de quién entra dónde | Las entradas quedan registradas en el controlador de dominio |

A cambio, el servidor pasa a ser **crítico**: si cae, nadie nuevo puede iniciar sesión (los equipos guardan en caché
los últimos inicios). Por eso en el grupo va en el clúster, y por eso su copia es importante. Necesita además un DNS
propio (el dominio se encuentra por DNS: `grupo3.lan`), y que los clientes usen ese DNS. En mi entorno no hay DHCP, así
que el DNS de cada cliente se cambiaría a mano.

## 8. Clientes

### 8.1 Windows 11 Pro

| Qué se pide | Cómo está |
|---|---|
| Versión y funcionamiento | Windows 11 **Pro** (la edición Home no puede unirse a un dominio), versión 23H2, compilación 22631.2861. 2 vCPU, 4 GB, 64 GB, EFI + Secure Boot + TPM 2.0. Instalación desatendida. Arranca sin problemas después del apagado brusco del 19/11 ([captura](../evidencies/t5-w11-red-y-carpeta-nas-20261121.png)) |
| Actualización | **Parcial.** De 5 pendientes se instalaron 4 (Windows Security, Defender y la herramienta de eliminación de software malintencionado): descarga en 9 min 15 s e instalación en 14 min 32 s. La **acumulativa 2025-11 (KB5068865) falló** con `0x800F0991`; después de `DISM /RestoreHealth`, Windows Update dejó de ofrecerla ([I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md)). Además, **la 23H2 ya no tiene soporte** (desde noviembre de 2025): antes de producción hay que subirlo a 24H2/25H2 |
| Usuarios de administración | `asix` (administrador local) y `Administrador` (integrado). El equipo está en `WORKGROUP`; al unirlo al dominio, los trabajadores entrarán con sus cuentas del dominio y `asix` quedará como cuenta local de emergencia |
| Red | `Ethernet` 192.168.30.100/24, puerta de enlace .1, DNS 172.16.222.1 (manual, sin DHCP) |
| Copia | Por SMB en `configuraciones\w11-direccion\20261121\`: lo mismo que el servidor (red, cortafuegos, directivas, usuarios, parches) más la lista de **aplicaciones** instaladas y los datos del equipo. 10 ficheros, 336 KB ([captura](../evidencies/t5-w11-copia-configuracion-nas-20261121.png)) |
| Qué no se copia | La imagen (14 GB) y los **documentos del usuario**: en la empresa, Dirección guardaría sus documentos en una carpeta del NAS, no en el disco del cliente. Así, si el equipo se estropea, se reinstala y no se pierde nada |

### 8.2 Debian 13 con GNOME

| Qué se pide | Cómo está |
|---|---|
| Versión y funcionamiento | Debian 13.8 con GNOME 48 (`deb-produccion`), 2 vCPU y 2 GB. Inicio de sesión gráfico comprobado ([captura](../evidencies/t5-cliente-linux-gnome-login-20261119.png), [estado](../evidencies/t5-cliente-linux-estado-20261119.txt)) |
| Usuarios de administración | `asix` (en el grupo `sudo`) y `root` |
| Red | Perfil `LAN_G3` de NetworkManager, manual: 192.168.30.101/24, gw .1, DNS 172.16.222.1. Con `no-auto-default=*`, para que NetworkManager no cree perfiles DHCP por su cuenta |
| Copia | `copia-config.sh` + temporizador diario: `/etc` (red, perfiles de NetworkManager, apt, sudoers) y lista de paquetes. **No** se copia `/home`: los documentos de los usuarios irían en una carpeta del NAS |

## 9. Servidores GNU/Linux de infraestructura

Los servidores Debian `.22` (servicios) y `.23` (datos) **se instalan solo en el trabajo de grupo**, como VMs del
clúster ([D-07](../decisions/D-07-servidores-debian-vm.md)): mi clúster está vacío ([D-04](../decisions/D-04-cluster-anidado-vacio.md)).
Lo que sí está preparado en el entorno individual para cuando existan: la carpeta de copias en el NAS, el
almacenamiento `nas-copias` en el clúster para sus copias `vzdump`, y el script `copia-config.sh`, que sirve tal cual
para cualquier Debian.

## 10. Problemas encontrados y solución

| # | Problema | Causa | Solución |
|---|---|---|---|
| 1 | La ISO de MikroTik no era adecuada para una VM | Era RouterOS **x86** (demo de 24 h sin licencia) | Imagen oficial **CHR 7.24.5** (VDI) |
| 2 | `opnsense.vdi` no arrancaba un sistema instalado | Era la imagen de instalación **live** | Se añadió un disco de 10 GB y se instaló en él |
| 3 | «No bootable medium found» en OPNsense | El firmware arranca del primer disco SATA y ahí estaba el vacío | Disco *live* en el puerto 0 para instalar; después solo el de sistema ([I-05](../incidencies/I-05-opnsense-no-arranca.md)) |
| 4 | El instalador de OPNsense avisaba de RAM insuficiente | Copiar la imagen *live* necesita unos 3 GB | Se instaló con 3 GB y después se bajó a 1 GB |
| 5 | El script de postinstalación de VirtualBox falló en Debian | Intenta instalar las Guest Additions | No afecta al sistema base |
| 6 | R3 se quedó sin DNS al reiniciar | `dhcpcd` sobrescribía `/etc/resolv.conf` | Se reescribió y se comprobó tras otro reinicio ([I-02](../incidencies/I-02-dns-r3-tras-reinicio.md)) |
| 7 | El ping a 8.8.8.8 falla en el aula | La red del aula filtra el ICMP hacia Internet | Las pruebas de NAT se hacen con TCP/80 |
| 8 | La descarga de la imagen CHR se cortaba | Conexión inestable con HTTP/2 | `curl --http1.1 -C -` y verificación del ZIP |
| 9 | `apt` se quedaba colgado en casa | El DNS del centro no existe fuera del aula | DNS `10.0.2.3` solo mientras se actualiza ([I-04](../incidencies/I-04-dns-fuera-del-aula.md)) |
| 10 | La regla de bloqueo de OPNsense no se aplicaba | La regla por defecto del modelo nuevo va antes que las reglas clásicas | Reglas creadas en el modelo nuevo ([I-06](../incidencies/I-06-opnsense-orden-reglas.md)) |
| 11 | OPNsense rechazaba el SSH tras actualizar | Kernel viejo con la base nueva: el reinicio no llegó a ejecutarse | Reinicio desde la consola ([I-07](../incidencies/I-07-opnsense-ssh-tras-actualizar.md)) |
| 12 | TrueNAS no podía comprobar actualizaciones | Nuestra propia regla de DNS externo de R1 | Desactivada solo durante la comprobación ([I-08](../incidencies/I-08-regla-dns-bloquea-actualizaciones.md)) |
| 13 | Los nodos Proxmox no cargaban el kernel nuevo | El reinicio lanzado en segundo plano moría al cerrarse la sesión SSH | Reinicio con `systemd-run --on-active=2`, uno a uno, comprobando el quórum |
| 14 | La primera copia de Proxmox llevaba claves privadas | `/etc/pve` incluye `priv/` | Exclusiones en `copia-config.sh` y copias borradas |
| 15 | WS2025 no arrancaba y se reinstalaba solo | Arranque dañado por un apagado brusco + disco auxiliar arrancable conectado | Reinstalación desatendida y medios quitados ([I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md)) |
| 16 | W11: la acumulativa falla con `0x800F0991` | Almacén de componentes y versión 23H2 sin soporte | `DISM /RestoreHealth`; sin resolver: subir de versión ([I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md)) |

## 11. Predicción y análisis

**Predicción** (antes de las pruebas del 21/11):

- Cada router dará salida a la LAN con NAT, y sin ningún router encendido la LAN no tendrá salida.
- Una regla `drop` con registro se verá en el log una vez por paquete bloqueado.
- Recuperar un router desde la copia será más rápido que configurarlo de nuevo.

**¿Se cumplió?**

- **Sí** en lo primero: los tres routers dan salida, y `LAN_G3` no tiene otra.
- **En parte** en lo segundo: se ve una línea por paquete, pero por cada intento salen **4 líneas** (los reintentos del
  SYN). La regla permitida, en cambio, solo registra el primer paquete de cada conexión.
- **Sí** en lo tercero: entre 1 y 57 s, frente a los minutos que costaría reescribir la configuración. Lo que no se
  esperaba es que el fallo de R2 tardara en notarse (caché ARP), y que el peor caso fuera un router que se queda
  **abierto** sin avisar (R3 sin `nftables.conf`).
- Lo que más tiempo ha costado no han sido las pruebas, sino los efectos secundarios de nuestras propias medidas: la
  regla de DNS bloqueando las actualizaciones (I-08) y los reinicios que no llegaban a ejecutarse (I-07, problema 13).
