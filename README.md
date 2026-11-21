# ASIX ThinkLab · «Naix un sistema» · Parte individual

Este es el trabajo individual sobre el proyecto que estamos haciendo en clase.

Proyecto intermodular de ASIX · CIP FP Batoi · curso 2026-2027 · **Grupo 3**
Red interna `192.168.30.0/24` · puerta de enlace `192.168.30.1` · DNS `172.16.222.1` · sin DHCP interno

Entorno de pruebas individual: VirtualBox 7.2 sobre Linux Mint 22.3 instalado en un disco externo,
que se arranca tanto en el PC de clase como en el de casa.

## Índice por tareas

| Tasca | Qué pide (individual) | Documento | Estado |
|---|---|---|---|
| PREDICE | Predicciones iniciales | [docs/00-prediccions.md](docs/00-prediccions.md) | ✏️ Por rellenar |
| 0 | Entorno de pruebas en el equipo propio, documentado en Git (VMs, recursos, problemas y solución) | [docs/00-entorno-pruebas.md](docs/00-entorno-pruebas.md) · [docs/05-recursos.md](docs/05-recursos.md) | ✅ Hecha |
| 1 | Requisitos y estudio de sistemas (grupal) | `docs/01-requisits.md` · `docs/03-sistemes.md` | — |
| 2 | Inventario y comparativa del PC de clase y el de casa, cuellos de botella y tests | [docs/02-inventari.md](docs/02-inventari.md) · [script](scripts/inventario-diagnostico.sh) | ✅ Hecha (tests solo en casa; clase con datos del montaje) |
| 4 | Esquema de red, montaje en VirtualBox y verificación de la conectividad | [docs/04-disseny.md](docs/04-disseny.md) · [diagrames/](diagrames/) | 🟡 Montaje y conectividad hechos (falta traceroute, Apte+) |
| 5 | Mismos sistemas que el grupo (comunicaciones, TrueNAS, Proxmox, WS2025, Debian, clientes) | [docs/06-servidores-comunicaciones.md](docs/06-servidores-comunicaciones.md) | 🟡 Sistemas instalados; faltan dominio, copias y pruebas de fallo |
| 6 | Tres tipos de RAID | `docs/07-raid.md` | ⏳ Pendiente |
| 7 | Análisis de recursos de la máquina física | [docs/05-recursos.md](docs/05-recursos.md) · `docs/08-rendimiento.md` | ⏳ Pendiente |

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| [`docs/`](docs/) | Documentación de cada tarea |
| [`diagrames/`](diagrames/) | Esquemas de red (lógico individual y referencia del grupo) |
| [`evidencies/`](evidencies/) | Capturas y salidas de comandos comentadas |
| [`configs/`](configs/) | Configuraciones reales exportadas de cada equipo |
| [`scripts/`](scripts/) | Scripts propios (inventario y diagnóstico de la Tasca 2) |

## Máquinas virtuales (grupo `/SOX-G3` de VirtualBox)

| VM | Sistema | IP LAN (`LAN_G3`) | RAM | Estado |
|---|---|---|---|---|
| R1-MikroTik-CHR | RouterOS 7.24.5 CHR · WAN NAT 10.0.2.15 | 192.168.30.1 | 256 MB | ✅ |
| R2-OPNsense | OPNsense 26.7 · WAN NAT 10.0.2.15 | 192.168.30.2 | 1 GB | ✅ |
| R3-Debian-nftables | Debian 13 + nftables · WAN NAT 10.0.2.15 | 192.168.30.3 | 512 MB | ✅ |
| NAS-TrueNAS | TrueNAS SCALE 25.10.7 (pool `copias`) | 192.168.30.20 | 3 GB | ✅ |
| WS2025 | Windows Server 2025 (fuera del clúster) | 192.168.30.21 | 2 GB | ✅ |
| PVE-1 / PVE-2 / PVE-3 | Proxmox VE 9.2 · clúster `cluster-g3` vacío | 192.168.30.32 / .33 / .34 | 1,5 GB c/u | ✅ |
| CLI-W11-Direccion | Windows 11 Pro | 192.168.30.100 | 4 GB | ✅ |
| CLI-Debian-Produccion | Debian 13 + GNOME | 192.168.30.101 | 2 GB | ✅ |

Todo encendido ocupa ~14,8 GB: en casa (16 GB) se trabaja por escenarios
([00-entorno-pruebas.md § 8](docs/00-entorno-pruebas.md#8-cuántas-máquinas-se-pueden-arrancar-a-la-vez)).

> Las credenciales se guardan fuera del repositorio. Las ISO y los discos virtuales no se suben
> (ver `.gitignore`).
