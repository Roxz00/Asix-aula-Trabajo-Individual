# 05 · Recursos de las máquinas virtuales

Resultado de la Tasca 4 (*docs/05-recursos.md* según el enunciado) y base de la Tasca 7 · **Parte individual**.

> Equipo anfitrión: Linux Mint 22.3 en disco externo · VirtualBox 7.2.18
> Se arranca en el **PC de clase** (18 hilos, ~30 GB de RAM) y en el **PC de casa** (i7-8700, 16 GB de RAM).
> El límite de diseño es el de **casa: 16 GB**.

## 1. Tabla de máquinas

Todas en el grupo `/SOX-G3` de VirtualBox.

| Nombre | Función | SO | vCPU | RAM | Disco | Red | Host | Estado |
|---|---|---|---|---|---|---|---|---|
| R1-MikroTik-CHR | Router principal / puerta de enlace | RouterOS 7.24.5 CHR | 1 | 256 MB | 128 MB | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| R2-OPNsense | Router / cortafuegos alternativo | OPNsense 26.7 (FreeBSD) | 1 | 1 GB | 10 GB (UFS) | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| R3-Debian-nftables | Router / cortafuegos GNU/Linux | Debian 13 + nftables | 1 | 512 MB | 8 GB | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| NAS-TrueNAS | Copias e imágenes | TrueNAS SCALE 25.10.7 | 2 | 3 GB | 16 GB sistema + 20 GB pool `copias` | LAN_G3 | VirtualBox | ✅ Funciona |
| WS2025 | Centralización del dominio (fuera del clúster) | Windows Server 2025 Standard, escritorio | 2 | 2 GB | 40 GB | LAN_G3 | VirtualBox | ✅ Instalado (dominio pendiente) |
| PVE-1 / PVE-2 / PVE-3 | Nodos del clúster `cluster-g3` (vacíos) | Proxmox VE 9.2 | 2 | 1,5 GB | 16 GB | LAN_G3 | VirtualBox (virtualización anidada) | ✅ Clúster con quórum |
| CLI-W11-Direccion | Cliente de Dirección | Windows 11 Pro 22H2 | 2 | 4 GB | 64 GB | LAN_G3 | VirtualBox | ✅ Funciona |
| CLI-Debian-Produccion | Cliente de Producción | Debian 13 + GNOME 48 | 2 | 2 GB | 20 GB | LAN_G3 | VirtualBox | ✅ Funciona |
| Debian-servicios / Debian-datos / LXC | Servidores virtuales | Debian 13 | — | — | — | — | Clúster Proxmox | Solo en el trabajo de grupo |

## 2. Requisitos mínimos oficiales frente a lo asignado

| Sistema | Mínimo oficial | Asignado | Fuente (consultada el 19/11/2026) |
|---|---|---|---|
| TrueNAS SCALE | 2 núcleos, **8 GB RAM**, disco de arranque de 16 GB | 2 vCPU, **3 GB**, 16 GB + 20 GB | [Guía de hardware de TrueNAS](https://www.truenas.com/docs/scale/gettingstarted/scalehardwareguide/) |
| Proxmox VE | CPU de 64 bits con VT-x/AMD-V, **1 GB RAM** (+ lo de las VMs) | 2 vCPU, **1,5 GB**, 16 GB | [Requisitos de Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/requirements) |
| Windows Server 2025 (escritorio) | 1,4 GHz 64 bits, **2 GB RAM**, 32 GB, UEFI + TPM 2.0 | 2 vCPU, **2 GB**, 40 GB, EFI + TPM 2.0 | [Requisitos de hardware de Windows Server](https://learn.microsoft.com/es-es/windows-server/get-started/hardware-requirements) |
| Windows 11 | 2 núcleos a 1 GHz, **4 GB RAM**, 64 GB, UEFI + Secure Boot + TPM 2.0 | 2 vCPU, **4 GB**, 64 GB, EFI + Secure Boot + TPM 2.0 | [Especificaciones de Windows 11](https://www.microsoft.com/es-es/windows/windows-11-specifications) |
| Debian 13 con escritorio | **1 GB RAM** (2 GB recomendado), 10 GB de disco | 2 vCPU, **2 GB**, 20 GB | [Guía de instalación de Debian, § 3.4](https://www.debian.org/releases/trixie/amd64/ch03s04.es.html) |

## 3. Justificación de cada decisión

| VM | Decisión | Por qué |
|---|---|---|
| R1 | 256 MB | En funcionamiento quedan unos 53 MB libres de 256 MB (`/system resource print`). |
| R2 | 1 GB · **UFS** | ZFS consume mucha más RAM. Se instaló con 3 GB porque el instalador los pide para copiar la imagen *live*, y después se bajó a 1 GB. |
| R3 | 512 MB | Sin entorno gráfico: usa unos 106 MB (`free -m`). Se instaló con 1 GB y después se bajó. |
| TrueNAS | **3 GB**, por debajo del mínimo | Para pruebas con pocos datos funciona: el pool se creó y el sistema responde. El mínimo de 8 GB es para producción (ZFS usa la RAM como caché). Con 8 GB no cabrían los escenarios en casa. |
| TrueNAS | Disco aparte de 20 GB | El enunciado pide un disco adicional para las copias. El pool `copias` está separado del de arranque, así que reinstalar el sistema no borra las copias. |
| Proxmox | 1,5 GB, nodos vacíos | Sin VMs dentro, cada nodo usa unos 1,2 GiB (`pvesh get /nodes`). Con 1 GB iría muy justo. |
| Proxmox | 16 GB de disco | Suficiente para el sistema; no se guardan VMs en los nodos. |
| WS2025 | 2 GB, escritorio | Es el mínimo con *experiencia de escritorio*, que facilita la gestión gráfica del dominio. |
| W11 | 4 GB y Pro | 4 GB es el mínimo que exige el instalador. La edición Pro es necesaria para unirse a un dominio. |
| Debian GNOME | 2 GB | Es el valor recomendado para escritorio. En la pantalla de inicio de sesión usa ~650 MB. |
| Todas las de la LAN | Solo adaptador `LAN_G3` | Así solo salen a Internet a través de un router (aislamiento). |

## 4. Recursos simultáneos

RAM real ocupada en el anfitrión por cada VM encendida (proceso `VBoxHeadless`, 19/11/2026):

| VM | RAM real |
|---|---|
| R1-MikroTik-CHR | 167 MB |
| R3-Debian-nftables | 348 MB |
| NAS-TrueNAS | 2.528 MB |
| WS2025 | 2.318 MB |
| CLI-W11-Direccion | 4.332 MB |
| CLI-Debian-Produccion | 976 MB |
| PVE-1 / PVE-2 / PVE-3 | ~1.365 MB cada uno |
| **Todas encendidas (sin R2)** | **14.762 MB** |

| Concepto | RAM |
|---|---|
| Reserva para el anfitrión (Linux Mint + VirtualBox) | ~3 GB estimados · **4,5 GB medidos** con las aplicaciones de uso normal ([Tasca 7](07-rendiment.md#5-cuántas-vms-puedo-usar-sin-bloquear-el-equipo)) |
| **Disponible para las VMs en casa** | **~13 GB** |
| Todas las VMs a la vez | ~14,8 GB → **no cabe en casa** |

Escenarios de trabajo en casa:

| Escenario | VMs | RAM aprox. |
|---|---|---|
| A · Comunicaciones | R1 + R2 + R3 | ~1,5 GB |
| B · Servidores y clientes | R1 + TrueNAS + WS2025 + W11 + Debian | ~10,3 GB |
| C · Clúster y copias | R1 + R3 + PVE-1/2/3 + TrueNAS | ~7,1 GB |

El análisis completo (CPU, disco y qué satura cada máquina) está en la [Tasca 7](07-rendiment.md).
