# Recursos de las máquinas virtuales (individual)

> Equipo anfitrión: Linux Mint 22.3 en disco externo · VirtualBox 7.2.18
> Se arranca en el **PC de clase** (18 hilos, ~30 GB de RAM) y en el **PC de casa** (16 GB de RAM).
> El límite de diseño es el de **casa: 16 GB**.

## 1. Tabla de máquinas

| Nombre | Función | SO | vCPU | RAM | Disco | Red | Host | Estado |
|---|---|---|---|---|---|---|---|---|
| R1-MikroTik-CHR | Router principal / puerta de enlace | RouterOS 7.24.5 CHR | 1 | 256 MB | 128 MB | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| R2-OPNsense | Router / cortafuegos alternativo | OPNsense 26.7 (FreeBSD) | 1 | 1 GB | 10 GB (UFS) | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| R3-Debian-nftables | Router / cortafuegos GNU/Linux | Debian 13 + nftables | 1 | 512 MB | 8 GB | NAT + LAN_G3 | VirtualBox | ✅ Funciona |
| NAS-TrueNAS | Copias e imágenes | TrueNAS SCALE 25.10 | N/C | N/C | N/C | LAN_G3 | VirtualBox | Pendiente |
| PVE-1 / PVE-2 / PVE-3 | Nodos del clúster | Proxmox VE | N/C | N/C | N/C | LAN_G3 | VirtualBox (virtualización anidada) | Pendiente |
| WS2025 | Dominio | Windows Server 2025 | N/C | N/C | N/C | LAN_G3 | Proxmox | Pendiente |
| Debian-servicios / Debian-datos | Infraestructura | Debian 13 | N/C | N/C | N/C | LAN_G3 | Proxmox | Pendiente |
| Clientes W11 / Linux | Puestos de trabajo | Windows 11 / Linux | N/C | N/C | N/C | LAN_G3 | VirtualBox | Pendiente |

**N/C** = no confirmado. Se completará al instalar cada máquina, con el requisito mínimo oficial
(fuente y fecha) y el valor propuesto para las pruebas.

## 2. Justificación de los routers

| VM | Decisión | Por qué |
|---|---|---|
| R1 | 256 MB | En funcionamiento quedan unos 53 MB libres de 256 MB (`/system resource print`). |
| R2 | 1 GB · **UFS** | ZFS consume mucha más RAM. Se instaló con 3 GB porque el instalador los pide para copiar la imagen *live*, y después se bajó a 1 GB. |
| R3 | 512 MB | Sin entorno gráfico: usa unos 106 MB (`free -m`). Se instaló con 1 GB y después se bajó. |

## 3. Recursos simultáneos

| Concepto | RAM |
|---|---|
| Reserva para el anfitrión (Linux Mint + VirtualBox) | ~3 GB (N/C, se medirá en la Tasca 7) |
| Tres routers encendidos | ~1,8 GB |
| **Disponible para el resto de VMs en casa** | **~11 GB** |

Con unos 11 GB no se podrá arrancar todo a la vez: los tres nodos Proxmox con sus VM dentro,
TrueNAS y los clientes. Se trabajará por escenarios (por ejemplo, routers + TrueNAS para las
copias, o routers + clúster). Las medidas reales se recogerán en la Tasca 7.
