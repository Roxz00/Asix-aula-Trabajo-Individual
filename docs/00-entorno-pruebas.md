# 00 · Montaje del entorno de pruebas

Tasca 0 «Muntatge de l'entorn de proves a l'aula» · RA principal: FDM RA1 · **Parte individual**.

> Grupo 3 · Red interna `192.168.30.0/24` · Fechas de montaje: 17/11/2026 (routers) y 19/11/2026 (resto)

## 1. Qué pedía la Tasca 0 y dónde está

| Lo que se pide | Nivel | Dónde está | Estado |
|---|---|---|---|
| Preparar el entorno propio de pruebas, que simule *"més o menys"* el del grupo | Apte | Apartados 3 a 7 | ✅ Hecho |
| Identificar los recursos físicos y justificar sus limitaciones | Apte | Apartados 2 y 8 · [05-recursos.md](05-recursos.md) · [02-inventari.md](02-inventari.md) | ✅ Hecho |
| Documentar el entorno en Markdown y Git: esquema de VMs, recursos y problemas resueltos | Apte+ | Apartados 4, 5 y 9 · este repositorio | ✅ Hecho |

Los detalles de cada router están en [05-installacions.md](05-installacions.md).

## 2. Equipo anfitrión

| | PC de clase | PC de casa |
|---|---|---|
| Sistema | Linux Mint 22.3 en **disco externo** (el mismo en los dos PCs) | ídem |
| Hipervisor | VirtualBox 7.2.18 | ídem |
| CPU | 18 hilos, VT-x | Intel Core i7-8700 (6 núcleos / 12 hilos, VT-x + EPT) |
| RAM | ~30 GB | **16 GB** → límite de diseño |
| Disco libre | ~245 GB en `/home` | ídem (es el mismo disco) |

Como el sistema va en un disco externo, el entorno es **el mismo** en clase y en casa: no hay que
recrearlo. Solo cambia la RAM disponible, por eso se diseña para 16 GB.

> En casa hay que comprobar una vez que la VT-x está activada en la BIOS (`grep -c vmx /proc/cpuinfo`
> debe ser mayor que 0). Sin ella no arrancan los nodos Proxmox, que usan virtualización anidada.

## 3. Qué se simula y en qué se diferencia del grupo

| Elemento | Montaje del grupo (aula) | Mi entorno individual | Motivo |
|---|---|---|---|
| Comunicaciones | MikroTik hEX físico + OPNsense y Debian en VM | Los tres en **VM** (MikroTik **CHR**) | No dispongo de un MikroTik físico |
| WAN de los routers | Red del aula (172.16.222.0/24) por NIC USB | **NAT de VirtualBox** | Funciona igual en clase y en casa |
| Switch LAN | TL-SG116 + LS1008G | Red interna de VirtualBox **`LAN_G3`** | La LAN queda aislada: solo sale por un router |
| NAS/SAN | TrueNAS en PC-02 | TrueNAS en **VM** con disco adicional para copias | |
| Clúster | 3 nodos Proxmox | 3 nodos Proxmox en **VM** (virtualización anidada), **vacíos** | Solo se simula la estructura; los servidores virtuales van en el trabajo de grupo |
| Windows Server 2025 | VM dentro del clúster | VM en VirtualBox, **fuera del clúster** | Decisión del grupo para el entorno individual |
| Debian servicios / datos | VMs dentro del clúster | **No se montan** | Se hacen en grupo |
| Clientes | 6 (3 Windows 11 + 3 Linux) | **2**: un W11 (Dirección) y un Debian con GNOME (Producción) | Uno de cada tipo cabe en 16 GB |
| Direccionamiento | Manual | Manual, **sin ningún DHCP interno** | Norma del enunciado: no lanzar un DHCP de pruebas |

## 4. Esquema de máquinas virtuales

- **Esquema lógico:** [diagrames/esquema-individual.md](../diagrames/esquema-individual.md)
- **Referencia del grupo:** [diagrames/arquitectura-referencia-grupo3.png](../diagrames/arquitectura-referencia-grupo3.png)

```
                    Internet ── red del aula / casa ── anfitrión (Linux Mint + VirtualBox)
                                                          │ NAT VBox (uno por router)
                            ┌─────────────────────────────┼─────────────────────────────┐
                     R1 MikroTik .1                 R2 OPNsense .2              R3 Debian+nftables .3
                            └─────────────────────────────┼─────────────────────────────┘
                                          red interna LAN_G3 · 192.168.30.0/24
        ┌───────────────┬──────────────┬────────┴───────┬───────────────────┬───────────────────┐
   TrueNAS .20     WS2025 .21    PVE-1 .32 · PVE-2 .33 · PVE-3 .34     W11 .100          Debian GNOME .101
   (pool copias)  (fuera clúster)   clúster «cluster-g3» (vacío)     (Dirección)        (Producción)
```

## 5. Máquinas y recursos asignados

Todas están en el grupo **`/SOX-G3`** de VirtualBox. Resumen (justificación completa en
[05-recursos.md](05-recursos.md)):

| VM | Función | SO | vCPU | RAM | Disco | Red | IP |
|---|---|---|---|---|---|---|---|
| R1-MikroTik-CHR | Router principal (puerta de enlace) | RouterOS 7.24.5 CHR | 1 | 256 MB | 128 MB | NAT + LAN_G3 | .1 |
| R2-OPNsense | Router / cortafuegos alternativo | OPNsense 26.7 | 1 | 1 GB | 10 GB | NAT + LAN_G3 | .2 |
| R3-Debian-nftables | Router / cortafuegos alternativo | Debian 13 + nftables | 1 | 512 MB | 8 GB | NAT + LAN_G3 | .3 |
| NAS-TrueNAS | Copias de seguridad e imágenes | TrueNAS SCALE 25.10.7 | 2 | 3 GB | 16 GB sistema + **20 GB copias** | LAN_G3 | .20 |
| WS2025 | Centralización del dominio | Windows Server 2025 Standard (escritorio) | 2 | 2 GB | 40 GB | LAN_G3 | .21 |
| PVE-1 / PVE-2 / PVE-3 | Nodos del clúster `cluster-g3` | Proxmox VE 9.2 | 2 | 1,5 GB | 16 GB | LAN_G3 | .32 / .33 / .34 |
| CLI-W11-Direccion | Cliente de Dirección | Windows 11 Pro | 2 | 4 GB | 64 GB | LAN_G3 | .100 |
| CLI-Debian-Produccion | Cliente de Producción | Debian 13 + GNOME | 2 | 2 GB | 20 GB | LAN_G3 | .101 |

Configuración común de la LAN: máscara `255.255.255.0`, puerta de enlace `192.168.30.1` (R1),
DNS `172.16.222.1` (el del centro), dominio de nombres `grupo3.lan`.

## 6. Montaje

### 6.1 Routers (17/11/2026)

Detallado en [05-installacions.md § 4.1](05-installacions.md#41-instalación).
Cada router tiene el adaptador 1 en NAT (WAN) y el adaptador 2 en la red interna `LAN_G3`.

### 6.2 TrueNAS SCALE (.20)

1. VM con dos discos SATA: 16 GB (sistema) y 20 GB (copias). Sin adaptador NAT: solo `LAN_G3`.
2. Instalador de consola: destino el disco de **16 GB**. El instalador lista los discos al revés
   (`sda` = 20 GB, `sdb` = 16 GB), así que hay que fijarse en el tamaño. Usuario web `truenas_admin`.
3. Menú de consola → *Configure network interfaces*: `ipv4_dhcp = No`, alias `192.168.30.20/24`,
   aplicar y confirmar (si no se confirma, TrueNAS deshace el cambio en 60 s).
4. *Configure network settings*: hostname `nas`, dominio `grupo3.lan`, puerta de enlace
   `192.168.30.1`, DNS `172.16.222.1`.
5. Desde la LAN, por la API REST: zona horaria `Europe/Madrid` y pool **`copias`** sobre el disco de
   20 GB (`/mnt/copias`). Es el "disco adicional para las copias" que pide el enunciado.

### 6.3 Clúster Proxmox VE (.32 – .34)

1. Tres VMs iguales con **virtualización anidada** activada (`VBoxManage modifyvm PVE-n --nested-hw-virt on`).
2. Instalador en modo texto (*Terminal UI*): ext4 en el disco de 16 GB, España, `Europe/Madrid`,
   contraseña de `root`, FQDN `pveN.grupo3.lan`, IP fija, puerta de enlace `.1` y DNS `172.16.222.1`.
3. Después de instalar: teclado en español, repositorio *enterprise* desactivado y repositorio
   **`pve-no-subscription`** añadido (sin suscripción, el *enterprise* da error en `apt update`).
4. Creación del clúster en PVE-1 y unión de los otros dos:

```bash
# En pve1
pvecm create cluster-g3
# En pve2 y en pve3 (pide la contraseña de root de pve1)
pvecm add 192.168.30.32 --fingerprint <huella SHA-256 del certificado de pve1>
```

Los nodos quedan **sin ninguna VM ni contenedor**: el clúster solo simula la estructura de la empresa.

### 6.4 Windows Server 2025 (.21) y cliente Windows 11 (.100)

Instalación **desatendida** con `VBoxManage unattended install`:

| | WS2025 | CLI-W11-Direccion |
|---|---|---|
| Imagen | n.º 2 · Standard Evaluation (experiencia de escritorio) | n.º 6 · Windows 11 **Pro** (Home no se puede unir a un dominio) |
| Firmware | EFI + TPM 2.0 + Secure Boot | EFI + TPM 2.0 + Secure Boot (requisitos de W11) |
| NIC | Intel PRO/1000 MT (82540EM): Windows trae el controlador | ídem |
| Nombre | `WS2025` | `W11-DIRECCION` |
| Usuario | `asix` (administrador local) | `asix` (administrador local) |

La IP se fija en el propio proceso desatendido con un comando de postinstalación:

```bat
netsh interface ipv4 set address name="Ethernet" static 192.168.30.21 255.255.255.0 192.168.30.1
netsh interface ipv4 set dnsservers name="Ethernet" static 172.16.222.1 primary
netsh advfirewall firewall add rule name="ICMPv4-in" protocol=icmpv4:8,any dir=in action=allow
```

La última línea permite el ping entrante, que Windows bloquea por defecto, para poder hacer las
pruebas de conectividad. En el cliente es igual, con `192.168.30.100`.

### 6.5 Cliente Debian 13 con GNOME (.101)

1. Instalación desatendida con un *preseed* propio (copia de la plantilla de VirtualBox) que añade
   `tasksel: standard, desktop, gnome-desktop, ssh-server` y teclado español.
2. Durante la instalación la VM tuvo un **adaptador NAT temporal**: el *netinst* descarga unos 1.400
   paquetes y, a través de R1, el límite de 1 Mbps del CHR lo habría alargado horas (problema 12).
3. Perfil fijo de NetworkManager `LAN_G3`: `192.168.30.101/24`, puerta de enlace `.1`, DNS
   `172.16.222.1`. Se borró el perfil DHCP automático y se añadió `no-auto-default=*` para que
   NetworkManager no vuelva a crearlo.
4. VM apagada, adaptador cambiado de NAT a `LAN_G3` y reenvío de puerto temporal eliminado.

### 6.6 Gestión desde el anfitrión

El anfitrión no tiene interfaz en `LAN_G3` (así la LAN sigue aislada). Para administrar los equipos
internos se **salta por R3**, que tiene SSH redirigido en `127.0.0.1:2203`:

```bash
ssh -J asix@127.0.0.1:2203 root@192.168.30.32              # SSH a un nodo
ssh -p 2203 -L 8006:192.168.30.32:8006 asix@127.0.0.1      # web de Proxmox en https://localhost:8006
ssh -p 2203 -L 8443:192.168.30.20:443  asix@127.0.0.1      # web de TrueNAS en https://localhost:8443
```

## 7. Verificación

| Prueba | Resultado | Evidencia |
|---|---|---|
| Routers: IP, ruta, DNS y NAT | ✅ | [05 § 4.3](05-installacions.md#43-red-wan-y-lan-e-internet-desde-la-lan) |
| TrueNAS: IP fija, gateway, DNS, pool `copias` ONLINE, salida a Internet | ✅ | [t5-truenas-estado-20261119.txt](../evidencies/t5-truenas-estado-20261119.txt) · [captura](../evidencies/t5-truenas-instalacion-completada-20261119.png) |
| Nodos Proxmox: IP fija, ping a `.1` y a `172.16.222.1`, DNS, HTTP 200 por R1 | ✅ (×3) | [t5-proxmox-estado-cluster-y-red-20261119.txt](../evidencies/t5-proxmox-estado-cluster-y-red-20261119.txt) |
| Clúster `cluster-g3`: 3 nodos, 3 votos, quórum 2, *Quorate: Yes*, 0 VMs | ✅ | [t5-proxmox-estado-cluster-y-red-20261119.txt](../evidencies/t5-proxmox-estado-cluster-y-red-20261119.txt) |
| Prueba de quórum (apagar nodos uno a uno y recuperar) | ✅ | [t5-proxmox-prueba-quorum-20261119.txt](../evidencies/t5-proxmox-prueba-quorum-20261119.txt) |
| WS2025: IP `.21`, gateway, DNS, resolución y ping al router | ✅ | [t5-ws2025-verificacion-red-20261119.png](../evidencies/t5-ws2025-verificacion-red-20261119.png) · [captura](../evidencies/t5-ws2025-escritorio-instalado-20261119.png) |
| W11: IP `.100`, gateway, DNS, resolución y ping al router | ✅ | [t5-w11-verificacion-red-20261119.png](../evidencies/t5-w11-verificacion-red-20261119.png) · [captura](../evidencies/t5-w11-escritorio-instalado-20261119.png) |
| Debian GNOME: IP `.101` manual, DNS, ping a TrueNAS, HTTP 200 por R1 | ✅ | [t5-cliente-linux-estado-20261119.txt](../evidencies/t5-cliente-linux-estado-20261119.txt) · [captura](../evidencies/t5-cliente-linux-gnome-login-20261119.png) |
| Ningún DHCP en la LAN | ✅ | Todas las IPs son manuales; los routers no tienen servidor DHCP ([05 § 4.3](05-installacions.md#43-red-wan-y-lan-e-internet-desde-la-lan)) |

### Prueba de quórum

| Nodos encendidos | Votos | ¿Quórum? | Escritura en `/etc/pve` |
|---|---|---|---|
| 3 | 3 de 3 | ✅ Sí | Permitida |
| 2 (PVE-3 apagado) | 2 de 3 | ✅ Sí | Permitida |
| 1 (PVE-2 y PVE-3 apagados) | 1 de 3 | ❌ No (*Activity blocked*) | **Bloqueada** |
| 3 (se vuelven a encender) | 3 de 3 | ✅ Sí | Se recupera sola |

Con 3 nodos el clúster aguanta la caída de uno. Si se queda un nodo solo, se bloquea para no
arriesgar un *split-brain*.

## 8. ¿Cuántas máquinas se pueden arrancar a la vez?

RAM del anfitrión que ocupa cada VM encendida (memoria residente del proceso `VBoxHeadless`,
medida el 19/11/2026 en el PC de clase):

| VM | RAM asignada | RAM real en el anfitrión |
|---|---|---|
| R1-MikroTik-CHR | 256 MB | 167 MB |
| R3-Debian-nftables | 512 MB | 348 MB |
| NAS-TrueNAS | 3 GB | 2.528 MB |
| WS2025 | 2 GB | 2.318 MB |
| CLI-W11-Direccion | 4 GB | 4.332 MB |
| CLI-Debian-Produccion (en la pantalla de inicio de sesión) | 2 GB | 976 MB |
| PVE-1 / PVE-2 / PVE-3 (vacíos) | 1,5 GB c/u | ~1.365 MB c/u |
| **Todo encendido (sin R2)** | | **14.762 MB** |

Con todo encendido las VMs ocupan unos 14,8 GB. En el PC de clase cabe (quedaban ~8,9 GB
disponibles), pero **en casa no**: 16 GB menos el sistema anfitrión no da. Por eso en casa se
trabaja por escenarios:

| Escenario | VMs | RAM aprox. | ¿Cabe en 16 GB? |
|---|---|---|---|
| A · Comunicaciones | R1 + R2 + R3 | ~1,5 GB | ✅ |
| B · Servidores y clientes | R1 + TrueNAS + WS2025 + W11 + Debian | ~10,3 GB | ✅ justo |
| C · Clúster y copias | R1 + R3 (salto) + PVE-1/2/3 + TrueNAS | ~7,1 GB | ✅ |
| D · Todo a la vez | Las 10 VMs | ~15–16 GB | ❌ solo en clase |

El análisis detallado (CPU, disco y saturación) está en la Tasca 7 ([07-rendiment.md](07-rendiment.md)). Con las aplicaciones de uso normal abiertas, el escenario B **no cabe** en casa ([07 § 5](07-rendiment.md#5-cuántas-vms-puedo-usar-sin-bloquear-el-equipo)).

## 9. Problemas encontrados y solución

Los problemas 1 a 8 son de los routers y están en
[05-installacions.md § 10](05-installacions.md#10-problemas-encontrados-y-solución).

| # | Problema | Causa | Solución |
|---|---|---|---|
| 9 | El instalador de TrueNAS mostraba el disco de copias como `sda` | El orden de los nombres no coincide con el puerto SATA | Se eligió el destino por el **tamaño** (16 GB) y no por el nombre |
| 10 | TrueNAS arrancó sin acceso web | No hay DHCP en la LAN (es lo esperado) | IP fija desde el menú de consola, confirmando el cambio antes de 60 s |
| 11 | En el instalador de Proxmox, caracteres como `/` podían salir cambiados | Los textos se escribieron desde el anfitrión, que envía códigos de teclado US, y el instalador propone teclado alemán | Se instaló con teclado US y después se cambió a español en `/etc/default/keyboard` |
| 12 | Las descargas por R1 iban a ~115 kB/s | La licencia gratuita del **CHR limita la subida a 1 Mbps** por interfaz | Para el *netinst* del cliente Debian se usó un NAT temporal solo durante la instalación |
| 13 | Latencia de ~100 ms y pérdidas hacia R1 con los Windows encendidos | Windows Update satura el enlace limitado de R1 | Es una limitación conocida. Para descargas grandes se puede cambiar la puerta de enlace a R2 o R3, que no tienen límite |
| 14 | `apt update` daba error en los nodos Proxmox | El repositorio *enterprise* necesita suscripción | Se desactivó y se añadió `pve-no-subscription` |
| 15 | `pvecm add` se quedaba esperando sin hacer nada | La salida iba a una tubería y la petición de contraseña no se veía | Se ejecutó en una terminal interactiva (`ssh -t`) |
| 16 | Al borrar el perfil DHCP del cliente Debian se cortó la sesión SSH | Era la conexión activa | Previsto: después se apagó la VM y se cambió el adaptador a `LAN_G3` |
| 17 | Las Guest Additions no quedaron activas en los Windows (`guestcontrol` no responde) | Sin confirmar: no se ejecutaron en la postinstalación desatendida | No afectan a la red. La verificación se hizo desde la consola (`cmd`) con capturas. Se pueden instalar a mano desde *Dispositivos → Insertar imagen de CD de las Guest Additions* |

## 10. Qué quedaba pendiente al montar el entorno y cómo terminó

Al cerrar la Tasca 0 quedaban estos puntos para las tareas siguientes:

| Punto | Estado | Dónde está |
|---|---|---|
| **Copias** de las configuraciones de routers, nodos, WS2025 y clientes en el pool `copias` de TrueNAS | ✅ Hecho y automatizado | [05-installacions § 3.3–3.4](05-installacions.md#33-espacio-de-copias-en-truenas-qué-cómo-y-dónde) · [D-08](../decisions/D-08-copias-de-configuracion.md) |
| Pruebas de **fallo y recuperación** de cada equipo | ✅ Hecho en los tres routers (1–57 s) y en WS2025 (reinstalación) | [05-installacions § 4.6](05-installacions.md#46-fallo-controlado-y-recuperación) · [I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md) |
| OPNsense: exportar `config.xml` | ✅ Hecho, copiado al NAS por `scp` | [05-installacions § 4.5](05-installacions.md#45-copia-en-el-servidor-de-copias) |
| OPNsense: cambiar el nombre de equipo | ❌ No se hizo: sigue como `OPNsense.internal`. No afecta al funcionamiento ni a las copias, que se guardan en la carpeta `r2-opnsense` | — |
| Promover **WS2025** a controlador de dominio y unir los clientes | ➖ No se hace en esta actividad: el enunciado deja la implantación de dominios para los RA4 y RA5 de ISO, y unir los clientes es opcional («si així ho considereu»). Se explica qué es un dominio y qué aporta | [05-installacions § 7.3](05-installacions.md#73-qué-es-un-dominio-y-qué-aporta-a-la-empresa) |
