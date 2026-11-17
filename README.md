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
| 0 | Entorno de pruebas en el equipo propio, documentado en Git (VMs, recursos, problemas y solución) | Este README · [docs/05-recursos.md](docs/05-recursos.md) · [problemas](docs/06-servidores-comunicaciones.md#6-problemas-encontrados-y-solución) | 🟡 En curso |
| 1 | Requisitos y estudio de sistemas (grupal) | `docs/01-requisits.md` · `docs/03-sistemes.md` | — |
| 2 | Inventario y comparativa del PC de clase y el de casa, cuellos de botella y tests | `docs/02-inventari.md` | ⏳ Pendiente |
| 4 | Esquema de red, montaje en VirtualBox y verificación de la conectividad | [docs/04-disseny.md](docs/04-disseny.md) · [diagrames/](diagrames/) | 🟡 Routers hechos |
| 5 | Mismos sistemas que el grupo (comunicaciones, TrueNAS, Proxmox, WS2025, Debian, clientes) | [docs/06-servidores-comunicaciones.md](docs/06-servidores-comunicaciones.md) | 🟡 Routers hechos |
| 6 | Tres tipos de RAID | `docs/07-raid.md` | ⏳ Pendiente |
| 7 | Análisis de recursos de la máquina física | [docs/05-recursos.md](docs/05-recursos.md) · `docs/08-rendimiento.md` | ⏳ Pendiente |

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| [`docs/`](docs/) | Documentación de cada tarea |
| [`diagrames/`](diagrames/) | Esquemas de red (lógico individual y referencia del grupo) |
| [`evidencies/`](evidencies/) | Capturas y salidas de comandos comentadas |
| [`configs/`](configs/) | Configuraciones reales exportadas de cada equipo |

## Máquinas virtuales (grupo `/SOX-G3` de VirtualBox)

| VM | Sistema | WAN (NAT) | LAN (`LAN_G3`) | RAM | Estado |
|---|---|---|---|---|---|
| R1-MikroTik-CHR | RouterOS 7.24.5 CHR | 10.0.2.15/24 | 192.168.30.1/24 | 256 MB | ✅ |
| R2-OPNsense | OPNsense 26.7 | 10.0.2.15/24 | 192.168.30.2/24 | 1 GB | ✅ |
| R3-Debian-nftables | Debian 13 + nftables | 10.0.2.15/24 | 192.168.30.3/24 | 512 MB | ✅ |

> Las credenciales se guardan fuera del repositorio. Las ISO y los discos virtuales no se suben
> (ver `.gitignore`).
