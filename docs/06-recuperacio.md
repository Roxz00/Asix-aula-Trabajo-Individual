# 06 · Almacenamiento y recuperación

Tasca 6 «Emmagatzematge i recuperació» · RA principal: ISO RA3 a-h · **Parte individual**.

> Grupo 3 · Red `192.168.30.0/24` · Pruebas: 22/11/2026 (PC de casa) · Discos virtuales y **datos ficticios**
> Script de las pruebas: [scripts/t6-raid.sh](../scripts/t6-raid.sh) · Credenciales: **fuera del repositorio**

## 1. Qué pedía la Tasca 6 y dónde está

En la parte individual, el enunciado pide el **punto 2** (Apte) y el **punto 3** (Apte+). Los puntos 1 (sistemas de
ficheros) y 4 (plan de contingencia) son del trabajo de grupo.

| Lo que se pide | Nivel | Dónde está | Estado |
|---|---|---|---|
| Crear y verificar al menos tres tipos de RAID | Apte | [3](#3-tres-tipos-de-raid-creación-y-verificación) · [4](#4-qué-pasa-cuando-falla-un-disco) · [t6-raid-creacion-y-fallos](../evidencies/t6-raid-creacion-y-fallos-20261122.txt) | ✅ Hecho (RAID 0, 1 y 5) |
| Explicar qué aporta cada tipo de RAID | Apte | [5](#5-qué-aporta-cada-tipo-de-raid) | ✅ Hecho |
| Investigar y justificar el espejo entre discos de dos equipos distintos | Apte+ | [6.1](#61-investigación-cómo-hacer-un-espejo-entre-dos-equipos) · [D-09](../decisions/D-09-espejo-entre-equipos-iscsi.md) | ✅ Hecho |
| Implementar el espejo entre dos equipos con la solución escogida | Apte+ | [6.2](#62-montaje-raid-1-entre-deb-produccion-y-el-nas) · [t6-espejo-iscsi](../evidencies/t6-espejo-iscsi-dos-equipos-20261122.txt) | ✅ Hecho (mdadm + iSCSI) |
| Verificar su funcionamiento y explicar un caso de uso | Apte+ | [6.3](#63-verificación-se-cae-cada-uno-de-los-dos-equipos) · [6.4](#64-caso-de-uso) | ✅ Hecho |
| Sistemas de ficheros (punto 1) y plan de contingencia (punto 4) | Grupo | [Repositorio del grupo](https://github.com/varo010/asix-aula-grup-03-ISO), `docs/06-recuperacio.md` | En el trabajo de grupo |

## 2. Dónde se hacen las pruebas

| Dato | Valor |
|---|---|
| Equipo | `deb-produccion` (CLI-Debian-Produccion, 192.168.30.101) · Debian 13.8 · 2 GB de RAM |
| Herramienta | `mdadm` 4.4 (RAID por software de Linux) y `open-iscsi` para el disco remoto |
| Discos | 9 discos virtuales de **256 MB** (VDI dinámicos) en los puertos SATA 1-9, marcados como *hot-pluggable* para poder quitarlos con la VM encendida |
| Equipo remoto (Apte+) | NAS-TrueNAS (192.168.30.20), que sirve un disco por **iSCSI** |
| Datos | `clientes-ficticios.csv` (20 000 filas inventadas) e `imagen-ficticia.bin` (60 MB aleatorios), con un fichero `SHA256SUMS` para comprobar después que no se ha perdido nada |
| Memoria del PC | Encendidos R1, R3, NAS y cliente: unos **5,6 GB** de los 16 GB (medido como en la [Tasca 7](07-rendiment.md#4-qué-satura-cada-máquina-virtual)), siempre con más de 2 GB libres |

**Por qué el cliente Debian.** El enunciado pide los RAID «en uno de los equipos». En el diseño, el sitio natural
sería el Debian de datos (.23), pero ese servidor solo existe en el montaje del grupo
([D-07](../decisions/D-07-servidores-debian-vm.md)). `deb-produccion` es un Debian completo que ya estaba
instalado y cabe en la memoria junto al NAS. Montar una VM nueva solo para esto habría costado otra instalación sin
aportar nada a la prueba. Los RAID usan discos aparte y **no tocan el disco del sistema**.

Cómo se provoca cada fallo:

- **Avería de un disco:** se quita el disco en caliente desde el anfitrión, como si se arrancara el cable:
  `VBoxManage storageattach … --port N --medium none`.
- **Fallo lógico:** `mdadm --fail`, que es lo que hace el propio sistema cuando un disco da errores.
- **Caída del otro equipo:** se desconecta el cable de red virtual del NAS con `setlinkstate1 off`.

## 3. Tres tipos de RAID: creación y verificación

| RAID | Dispositivo | Discos | Comando de creación | Montado en |
|---|---|---|---|---|
| **RAID 0** (reparto) | `md0` | sdb + sdc | `mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc` | `/srv/raid0` |
| **RAID 1** (espejo) | `md1` | sdd + sde | `mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sdd /dev/sde` | `/srv/raid1` |
| **RAID 5** (paridad) | `md5` | sdf + sdg + sdh | `mdadm --create /dev/md5 --level=5 --raid-devices=3 /dev/sdf /dev/sdg /dev/sdh` | `/srv/raid5` |

Después: `mkfs.ext4 -L raidN`, montaje y copia de los datos ficticios. La sincronización inicial de md1 y md5 tardó
**2,1 s**. Todos quedaron sanos: `[UU]` y `[UUU]` en `/proc/mdstat`, `State : clean` en `mdadm --detail`.

**Capacidad útil con discos de 256 MB** (medida con `df -h`):

| RAID | Discos | Espacio bruto | Tamaño del RAID | Útil en ext4 | Aprovechamiento |
|---|---|---|---|---|---|
| RAID 0 | 2 | 512 MB | 508 MiB | 466 MB | ~100 % (n discos) |
| RAID 1 | 2 | 512 MB | 255 MiB | 233 MB | 50 % (1 disco) |
| RAID 5 | 3 | 768 MB | 508 MiB | 466 MB | 66 % (n − 1 discos) |

**Velocidad secuencial** (100 MB aleatorios con `dd oflag=direct` / `iflag=direct`, dos pasadas):

| Volumen | Escritura | Lectura |
|---|---|---|
| Un disco solo (sdi) | 1,2–2,0 GB/s | 1,0–2,9 GB/s |
| RAID 0 | 705–779 MB/s | 1,4–1,6 GB/s |
| RAID 1 | 277–397 MB/s | 1,1–1,6 GB/s |
| RAID 5 | 308–328 MB/s | 1,2–1,3 GB/s |

Estas cifras **no son la velocidad real de un RAID**. Los 9 discos virtuales son ficheros dentro del **mismo disco
físico** del anfitrión y pasan por su caché, así que el RAID 0 no puede repartir el trabajo entre discos distintos y
sale incluso más lento que un disco solo. Lo único que sí se ve es el **coste de escritura**: el RAID 1 escribe todo
dos veces y el RAID 5 calcula la paridad, y por eso escriben a la mitad que el RAID 0. Con discos físicos
separados, el RAID 0 escribiría hasta n veces más rápido.

**Permanente.** Los RAID se guardaron en `/etc/mdadm/mdadm.conf` (`mdadm --detail --scan`) y en el initramfs, y se
añadieron a `/etc/fstab` por **etiqueta** y con `nofail`, para que un RAID roto no impida arrancar. Tras reiniciar se
montan solos y los datos coinciden. Los nombres `sdX` cambian de un arranque a otro; mdadm reconoce sus discos por el
UUID, así que no importa.

## 4. Qué pasa cuando falla un disco

| RAID | Fallo provocado | Qué se vio | Datos | Recuperación | Tiempo |
|---|---|---|---|---|---|
| **RAID 0** | Se quita sdc en caliente | `I/O error, dev sdc` · `Buffer I/O error on dev md0` · md0 pasa a `broken raid0` | ❌ `imagen-ficticia.bin: FAILED open or read`. El CSV aún se leía porque cabía entero en un trozo de 512 KB que estaba en sdb | **No hay**: se rehace el RAID vacío. Los datos solo se recuperarían de una copia | — (datos perdidos) |
| **RAID 1** | Se quita sde en caliente | `md1 : active raid1 sde[1](F) sdd[0]` · `[2/1] [U_]` · `State : active, degraded` | ✅ Las dos sumas coinciden y se puede seguir escribiendo | `mdadm --add /dev/sdi` (disco nuevo) | **0 s** sin servicio · reconstrucción **1,3 s** |
| **RAID 5** | `mdadm --fail /dev/sdg` | `State : clean, degraded` · 2 de 3 discos | ✅ Las sumas coinciden: lo que faltaba se calcula con la paridad | Disco borrado (como si fuera nuevo) y `--add` | **0 s** sin servicio · reconstrucción **7,1 s** |

Lo importante:

- En RAID 1 y RAID 5 **el servicio no se para**: el fallo solo se ve en `/proc/mdstat` y en `mdadm --detail`. Por eso
  `mdadm --monitor`, que Debian activa al instalar mdadm, es necesario: sin avisos, un RAID degradado puede pasar
  desapercibido hasta que falla el segundo disco.
- La reconstrucción del RAID 5 tarda más que la del RAID 1 (7,1 s frente a 1,3 s) con la misma cantidad de datos:
  tiene que leer **todos** los discos y recalcular la paridad. Con discos de varios TB son horas, y durante ese
  tiempo el RAID no aguanta otro fallo.
- El disco quitado del RAID 1 se borró (`--zero-superblock`) y quedó como **repuesto en caliente**
  (en `/proc/mdstat` aparece con la marca `(S)`, de *spare*). Si falla otro disco, mdadm reconstruye solo con él.

## 5. Qué aporta cada tipo de RAID

| | RAID 0 | RAID 1 | RAID 5 | RAID 6 / RAID 10 (no probados) |
|---|---|---|---|---|
| Cómo guarda los datos | Reparte cada fichero en trozos entre los discos | Copia idéntica en cada disco | Reparte datos y una paridad que va rotando de disco | RAID 6: dos paridades · RAID 10: espejos repartidos |
| Discos mínimos | 2 | 2 | 3 | 4 |
| Espacio útil | Todo (n) | La mitad (1 disco) | n − 1 | RAID 6: n − 2 · RAID 10: la mitad |
| Fallos que aguanta | **Ninguno**: si cae uno, se pierde todo | 1 (con 2 discos) | 1 | RAID 6: 2 cualesquiera · RAID 10: 1 por espejo |
| Rendimiento | El más rápido leyendo y escribiendo | Lee como 2 discos y escribe como 1 | Lee rápido, pero escribir cuesta más (paridad) | RAID 10: rápido · RAID 6: escritura más lenta |
| Qué ganamos | Velocidad y espacio | Seguridad y simplicidad | Seguridad aprovechando más el espacio | Más seguridad en discos grandes |
| Dónde lo pondría | Datos temporales o que se pueden regenerar (caché, renderizado) | Disco del sistema de un servidor, servidor pequeño | NAS o servidor de ficheros con 3-5 discos | Discos grandes (RAID 6) o bases de datos (RAID 10) |

**Un RAID no es una copia de seguridad.** Protege de la **avería de un disco**, pero si se borra un fichero o se
estropea la configuración, el error se copia en todos los discos al momento. Por eso las copias de la
[Tasca 5](05-installacions.md#33-espacio-de-copias-en-truenas-qué-cómo-y-dónde) siguen siendo necesarias. Además,
todos los discos están en el mismo equipo: si se quema la fuente o el equipo entero, el RAID no sirve. Esto lleva al
apartado 6.

## 6. Espejo entre discos de dos equipos distintos (Apte+)

### 6.1 Investigación: cómo hacer un espejo entre dos equipos

Hay dos formas de hacerlo: llevar el disco del otro equipo por la red para que el sistema lo vea como uno más y
hacer un RAID normal, o usar un sistema que replica los datos entre equipos.

| Solución | Cómo funciona | Ventajas | Inconvenientes |
|---|---|---|---|
| **mdadm + iSCSI** | El NAS ofrece un disco por la red (iSCSI); Linux lo ve como `/dev/sdX` y hace RAID 1 con un disco local | Usa lo que ya tenemos (TrueNAS + mdadm); es el mismo RAID del apartado 3 | Si la red falla, las escrituras se paran unos segundos; solo un equipo usa el disco |
| **DRBD** | Módulo de Linux que replica un disco bloque a bloque a otro Linux (un «RAID 1 por red») | Pensado para esto; se integra con clústeres de alta disponibilidad (Pacemaker) | Necesita dos Linux con DRBD; hay que vigilar el *split-brain* |
| **Réplica de ZFS** (`zfs send/receive`) | Envía instantáneas de un pool a otro equipo cada cierto tiempo | Ya está en TrueNAS (*Replication Tasks*) | No es en tiempo real: se pierde lo escrito desde la última instantánea |
| **Ceph / GlusterFS** | Almacenamiento repartido entre 3 o más equipos | Escala mucho; Proxmox trae Ceph | Pide 3 nodos, mucha RAM y red rápida: no cabe en 16 GB |
| **Storage Replica** (Windows Server) | Réplica de un volumen entre dos Windows Server | Nativo en Windows | Necesita dos Windows Server; edición Datacenter para todo |

**Escogida: mdadm + iSCSI contra TrueNAS** ([D-09](../decisions/D-09-espejo-entre-equipos-iscsi.md)). No hace falta
encender otra VM, porque el NAS ya está encendido para las copias, y es un RAID 1 de verdad, en tiempo real, entre
dos equipos distintos. DRBD habría necesitado un segundo Debian solo para esto; Ceph no cabe en la memoria.

### 6.2 Montaje: RAID 1 entre deb-produccion y el NAS

**En el NAS (TrueNAS, por la API REST):**

| Objeto | Valor |
|---|---|
| zvol (disco virtual de ZFS) | `copias/espejo-deb` · 256 MiB · *sparse* |
| Portal | 192.168.30.20:3260 (solo la IP de la LAN) |
| Iniciador permitido | `iqn.2026-11.local.g3:deb-produccion` (ningún otro equipo puede conectarse) |
| Destino y LUN | `iqn.2005-10.org.freenas.ctl:espejo-deb` · extent `DISK` → LUN 0 |
| Servicio | `iscsitarget` activado al arrancar · `RUNNING` |

**En deb-produccion:**

```bash
echo "InitiatorName=iqn.2026-11.local.g3:deb-produccion" > /etc/iscsi/initiatorname.iscsi
iscsiadm -m discovery -t sendtargets -p 192.168.30.20
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:espejo-deb --op update -n node.startup -v automatic
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:espejo-deb --op update -n node.session.timeo.replacement_timeout -v 15
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:espejo-deb --login          # aparece como «TrueNAS iSCSI Disk»
mdadm --create /dev/md10 --level=1 --raid-devices=2 --bitmap=internal /dev/sdj --write-mostly /dev/sde
```

Tres opciones del montaje y para qué sirve cada una:

- **`--write-mostly`** en el disco remoto: las lecturas se hacen del disco local, que es más rápido; la red solo se
  usa para escribir.
- **`--bitmap=internal`**: mdadm apunta qué zonas han cambiado mientras falta un disco. Al volver, solo copia esas
  zonas y no los 256 MB enteros.
- **`replacement_timeout 15`**: el valor por defecto es 120 s. Si el NAS cae, el cliente se quedaría 2 minutos
  esperando antes de seguir solo con el disco local.

La sincronización inicial por la red tardó **1,6 s**. Tras copiar los datos ficticios, la API del NAS indica que el
zvol ocupa **60,86 MiB**: la imagen de 60 MB está físicamente en el otro equipo. Al reiniciar el cliente, la sesión
iSCSI se reconecta sola y `md10` se monta (fstab con `_netdev`).

### 6.3 Verificación: se cae cada uno de los dos equipos

| Prueba | Qué se hizo | Qué se vio | Datos | Vuelta a la normalidad | Tiempo |
|---|---|---|---|---|---|
| **1. Cae el NAS** (el otro equipo) | Cable de red del NAS desconectado y escritura en `/srv/espejo` | `ping timeout of 5 secs expired` → `session recovery timed out after 15 secs` → `md/raid1:md10: Disk failure on sde … Operation continuing on 1 devices` | ✅ Se siguió trabajando con el disco local; se escribieron 20 MB más | Cable conectado: la sesión iSCSI vuelve en 4 s y `mdadm --re-add` | Escritura **parada 20,4 s** · resincronización **1,0 s** |
| **2. Se avería el disco local** | Se quita sdj en caliente | `md10 : … sdj[0](F)` · `[2/1] [_U]` | ✅ Las sumas coinciden **leyendo solo del NAS**, y se pudo escribir (`solo-nas.txt`) | Disco reconectado y `mdadm --re-add` | **0 s** sin servicio · resincronización **1,0 s** |

Las dos resincronizaciones tardaron 1 s gracias al **bitmap**, aunque en la prueba 1 había 20 MB nuevos: solo se
copiaron las zonas que habían cambiado.

**La diferencia con el RAID 1 local** es que en la prueba 1 la escritura se **quedó parada 20 s**, el tiempo que
tarda en darse por perdido el equipo remoto. Las aplicaciones no fallan, pero esperan. Es el precio de tener la
copia en otro equipo. Se puede bajar el tiempo de espera, aunque con un valor muy bajo cualquier corte de red de
pocos segundos sacaría el disco del RAID.

### 6.4 Caso de uso

**Servidor de datos de una oficina pequeña con la segunda copia en el NAS de otra sala.**

- **Hoy:** el Debian de datos guarda los ficheros de los departamentos en su disco y una vez por noche se hace la
  copia (Tasca 5). Si el servidor se quema a las 17:00, se pierde todo el trabajo del día.
- **Con el espejo:** cada escritura va **a la vez** al disco local y al NAS. Si se avería el disco del servidor, sigue
  funcionando con el del NAS sin parar (prueba 2).
- **Si se pierde el servidor entero:** se conecta otro equipo al mismo destino iSCSI y se arranca el RAID solo con ese
  disco (`mdadm --assemble --run`). Los datos están al día, hasta la última escritura.

**Qué no cubre:**

- Un borrado o un virus se copian también al NAS al momento. Por eso las **instantáneas diarias** del NAS siguen
  siendo necesarias: con ellas se vuelve al día anterior.
- En mi entorno los dos «equipos» son VMs del mismo PC y del mismo disco externo: se demuestra el funcionamiento, no
  la protección real frente a la avería del PC.

## 7. Problemas encontrados y solución

| # | Problema | Causa | Solución |
|---|---|---|---|
| 1 | `mdadm`, `open-iscsi` no instalados y sin DNS en casa | El DNS del aula (172.16.222.1) no responde fuera del centro | Método de la Tasca 5 ([I-08](../incidencies/I-08-regla-dns-bloquea-actualizaciones.md)): salida por R3 y DNS 10.0.2.3 con una excepción temporal en nftables, que después se quitó |
| 2 | La primera medida de velocidad daba «0 GB/s» | `dd` en español usa coma decimal y rompía la columna; además se escribían ceros | `LC_ALL=C` y datos aleatorios desde la RAM (`/dev/shm`) |
| 3 | `mkfs.ext4` se quedó esperando al rehacer el RAID 0 | El ext4 anterior seguía dentro de la zona de datos y pedía confirmación | `mkfs.ext4 -F` en el script |
| 4 | VirtualBox daba error al volver a conectar un disco | Con la VM encendida no se puede cambiar la marca *hot-pluggable* | Solo era un aviso: el disco sí se conectó (apareció como `sdk`) |

## 8. Predicción y análisis

**Predicción** (antes de las pruebas, ver también [00-prediccions](00-prediccions.md)):

- Con RAID 1 y RAID 5 se podrá quitar un disco sin perder datos; con RAID 0 se perderá todo.
- El RAID 0 será el más rápido.
- Un espejo por la red será más lento, pero funcionará igual que uno local.

**¿Se cumplió?**

- **Sí** en lo primero, con un matiz: en el RAID 0 los ficheros pequeños que caben en un solo trozo todavía se
  leían. Aun así, el RAID no se puede reparar y no hay forma de saber qué se ha salvado.
- **No** en lo segundo, en este entorno: todos los discos virtuales están en el mismo disco físico y el RAID 0 no
  ganó nada. La ventaja del RAID 0 depende de tener discos físicos distintos.
- **En parte** en lo tercero: funciona igual cuando todo va bien, pero si cae el otro equipo, las escrituras se paran
  20 s antes de seguir. Eso no pasa con un espejo local.
