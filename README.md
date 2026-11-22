# ASIX ThinkLab · Grupo 3 · Parte individual · «Naix un sistema: instal·la, configura i vigila'l»

Este es el trabajo individual sobre el proyecto que estamos haciendo en clase.

| Dato | Valor |
|---|---|
| Encargo | Entorno de pruebas individual que simula el sistema informático de la empresa del grupo |
| Grupo | 3 · repositorio del grupo: [varo010/asix-aula-grup-03-ISO](https://github.com/varo010/asix-aula-grup-03-ISO) |
| Entorno | VirtualBox 7.2 sobre Linux Mint 22.3 en un **disco externo**, que se arranca en el PC de clase y en el de casa |
| Límite de diseño | **16 GB de RAM** (PC de casa) |
| LAN | `192.168.30.0/24` (red interna de VirtualBox `LAN_G3`) · puerta de enlace `.1` · DNS `172.16.222.1` · **sin DHCP interno** |
| WAN de los routers | NAT de VirtualBox (`10.0.2.15`, puerta de enlace `10.0.2.2`) · [D-01](decisions/D-01-wan-por-nat.md) |
| Periodo | 17 – 22 nov 2026 (entrega de la documentación el domingo 22/11) |

## Alcance

Tres servidores de comunicaciones (MikroTik CHR, OPNsense y Debian con nftables), NAS TrueNAS con disco de copias,
clúster Proxmox VE de 3 nodos (anidado y vacío), Windows Server 2025 fuera del clúster y dos clientes
(Windows 11 Pro y Debian con GNOME). En qué se diferencia del montaje del grupo:
[00-entorno-pruebas § 3](docs/00-entorno-pruebas.md#3-qué-se-simula-y-en-qué-se-diferencia-del-grupo).

## Estado

| Tarea del enunciado | Documento | Entrega | Estado |
|---|---|---|---|
| PREDIU «Prediccions» | [00-prediccions](docs/00-prediccions.md) | — | Pendiente: las respuestas las escribo yo |
| Tasca 0 «Muntatge de l'entorn de proves» | [00-entorno-pruebas](docs/00-entorno-pruebas.md), [05-recursos](docs/05-recursos.md) | [PDF](lliuraments/Tasca0_Lliurament_Individual.pdf) | Ejecutado |
| Tasca 1 «Necessitats i sistemes» | Solo grupal | — | — |
| Tasca 2 «Equips i perifèrics» | [02-inventari](docs/02-inventari.md) | [PDF](lliuraments/Tasca2_Lliurament_Individual.pdf) | Ejecutado (tests solo en el PC de casa; el de clase con los datos del montaje) |
| Tasca 3 «Rack i interconnexió» | Solo grupal | — | — |
| Tasca 4 «Disseny físic i lògic» | [04-disseny](docs/04-disseny.md), [diagrames/](diagrames/) | [PDF](lliuraments/Tasca4_Lliurament_Individual.pdf) | Ejecutado (con ping, traceroute y tablas de rutas) |
| Tasca 5 «Instal·lació i comunicacions» | [05-installacions](docs/05-installacions.md) | [PDF](lliuraments/Tasca5_Lliurament_Individual.pdf) | Ejecutado (migración y servidores Debian: en el grupo) |
| Tasca 6 «Emmagatzematge i recuperació» | [06-recuperacio](docs/06-recuperacio.md) | [PDF](lliuraments/Tasca6_Lliurament_Individual.pdf) | Ejecutado (RAID 0, 1 y 5 + espejo iSCSI entre dos equipos) |
| Tasca 7 «Rendiment i diagnòstic» | `07-rendiment` | — | Pendiente (hay medidas de RAM en [05-recursos](docs/05-recursos.md)) |
| Tasca 8 (Final) | — | — | El 25/11, en clase |

Estados posibles: Pendiente · En curso · Ejecutado · Simulado.

## Máquinas virtuales (grupo `/SOX-G3` de VirtualBox)

| VM | Sistema | IP LAN (`LAN_G3`) | RAM | Estado |
|---|---|---|---|---|
| R1-MikroTik-CHR | RouterOS 7.25.1 CHR · WAN NAT 10.0.2.15 | 192.168.30.1 | 256 MB | ✅ |
| R2-OPNsense | OPNsense 26.7.9 · WAN NAT 10.0.2.15 | 192.168.30.2 | 1 GB | ✅ |
| R3-Debian-nftables | Debian 13.8 + nftables · WAN NAT 10.0.2.15 | 192.168.30.3 | 512 MB | ✅ |
| NAS-TrueNAS | TrueNAS SCALE 25.10.7 (pool `copias`: configuraciones, imágenes y el disco iSCSI `espejo-deb` de la Tasca 6) | 192.168.30.20 | 3 GB | ✅ |
| WS2025 | Windows Server 2025 (fuera del clúster) | 192.168.30.21 | 2 GB | ✅ |
| PVE-1 / PVE-2 / PVE-3 | Proxmox VE 9.2.32 · clúster `cluster-g3` vacío | 192.168.30.32 / .33 / .34 | 1,5 GB c/u | ✅ |
| CLI-W11-Direccion | Windows 11 Pro | 192.168.30.100 | 4 GB | ✅ |
| CLI-Debian-Produccion | Debian 13.8 + GNOME · RAID de la Tasca 6 (9 discos de 256 MB) | 192.168.30.101 | 2 GB | ✅ |

Todo encendido ocupa ~14,8 GB: en casa se trabaja por escenarios
([00-entorno-pruebas § 8](docs/00-entorno-pruebas.md#8-cuántas-máquinas-se-pueden-arrancar-a-la-vez)).

## Índice

- [docs/](docs/): documentación por tareas
- [decisions/](decisions/): decisiones justificadas del entorno individual y sus alternativas
- [incidencies/](incidencies/): incidencias con síntoma, hipótesis, prueba, solución y retorno
- [diagrames/](diagrames/): esquemas (Mermaid) y la referencia del grupo
- [evidencies/](evidencies/): capturas saneadas y salidas de comandos (`<tarea>-<descripcion>-<fecha>`)
- [configs/](configs/): configuraciones exportadas de cada equipo
- [scripts/](scripts/): inventario y diagnóstico (Tasca 2), copia automática de la configuración (Tasca 5) y generador de los PDF de entrega
- [lliuraments/](lliuraments/): PDF de entrega de cada tarea

## Cómo trabajo

1. Cada tarea se documenta en su fichero de [docs/](docs/), que empieza con la tabla «Qué pedía la tarea y dónde
   está» con los puntos de la rúbrica individual.
2. Las pruebas guardan su salida en [evidencies/](evidencies/) y el documento la explica.
3. Commits pequeños por tarea. Antes de cada commit se buscan contraseñas en lo que se va a subir.
4. Al cerrar una tarea se actualiza la tabla de estado y se genera su PDF.

Nunca se suben contraseñas, claves, números de serie, MAC, ISOs ni discos virtuales (ver [.gitignore](.gitignore)).
Las credenciales del laboratorio se guardan fuera del repositorio.
