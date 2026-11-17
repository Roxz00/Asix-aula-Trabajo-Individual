# Tasca 4 · Diseño físico y lógico (individual)

> Grupo 3 · Red interna `192.168.30.0/24` · Fecha: 17/11/2026

## 1. Esquemas

- **Esquema lógico individual (VirtualBox):** [diagrames/esquema-individual.md](../diagrames/esquema-individual.md)
- **Arquitectura de referencia del grupo:** [diagrames/arquitectura-referencia-grupo3.png](../diagrames/arquitectura-referencia-grupo3.png)

El entorno individual simula el del grupo, aunque no es una copia exacta (lo permite el enunciado).
La diferencia principal está en la WAN de los routers: en clase OPNsense y Debian salen en puente
por una NIC USB, mientras que aquí la WAN usa el **NAT de VirtualBox**.

## 2. Plan de direccionamiento

Red `192.168.30.0/24` · máscara `255.255.255.0` · puerta de enlace `192.168.30.1` · DNS `172.16.222.1`.

| Rango | Uso |
|---|---|
| `.1 – .15` | Comunicaciones (MikroTik `.1`, OPNsense `.2`, Debian nftables `.3`) y anfitrión (`.15`) |
| `.16 – .99` | Servidores |
| `.100 – .200` | Clientes (PC físicos y virtuales) |

| Equipo | IP | Asignación | Estado |
|---|---|---|---|
| R1-MikroTik-CHR (LAN) | 192.168.30.1/24 | Manual | ✅ |
| R2-OPNsense (LAN) | 192.168.30.2/24 | Manual | ✅ |
| R3-Debian-nftables (LAN) | 192.168.30.3/24 | Manual | ✅ |
| Anfitrión | 192.168.30.15/24 | Manual | — |
| NAS/SAN TrueNAS | 192.168.30.20/24 | Manual | Pendiente |
| VM Windows Server 2025 | 192.168.30.21/24 | Manual | Pendiente |
| VM Debian · servicios | 192.168.30.22/24 | Manual | Pendiente |
| VM Debian · datos | 192.168.30.23/24 | Manual | Pendiente |
| Nodos Proxmox VE 1 / 2 / 3 | 192.168.30.32 / .33 / .34 /24 | Manual | Pendiente |
| Clientes (Dirección, Administración, Comercial, Producción, Informática, portátil) | .100 – .200 | Manual | Pendiente |

### Método de asignación: todo manual, sin DHCP

Dentro de la empresa **no hay ningún servidor DHCP**: ni los routers ni los servidores reparten
direcciones, y todas las IPs internas se configuran a mano. El único DHCP es el externo (el router
de casa o el servidor DHCP del centro), que da IP al anfitrión.

Así se cumple la norma del enunciado de no lanzar un DHCP de pruebas sobre la red compartida.
Además, cada equipo tiene siempre la misma IP, lo que facilita las reglas de cortafuegos y las copias.

## 3. Montaje en VirtualBox

| Adaptador | Modo | Red | Por qué |
|---|---|---|---|
| Adaptador 1 (WAN) | **NAT** | `10.0.2.0/24` (privada de cada VM) | Salida a Internet a través del anfitrión, tanto en clase como en casa |
| Adaptador 2 (LAN) | **Red interna** | `LAN_G3` | LAN aislada: solo sale a Internet atravesando un router |

En el modo NAT de VirtualBox:
- la IP de la VM es `10.0.2.15`;
- la puerta de enlace es `10.0.2.2`, que es el propio motor NAT;
- `10.0.2.3` es el DNS interno de VirtualBox.

Cada VM tiene **su propio motor NAT**, así que los tres routers pueden usar `10.0.2.15` a la vez
sin conflicto.

**Acceso de gestión desde el anfitrión:** redirección de puertos del NAT **solo en `127.0.0.1`**,
para no exponer nada a la red del aula.

| VM | Puerto anfitrión → VM |
|---|---|
| R1-MikroTik-CHR | `127.0.0.1:2201 → 22` (SSH) · `127.0.0.1:8291 → 8291` (Winbox) |
| R2-OPNsense | `127.0.0.1:2202 → 22` · `127.0.0.1:8402 → 443` (bloqueados por defecto por el cortafuegos WAN de OPNsense) |
| R3-Debian-nftables | `127.0.0.1:2203 → 22` (SSH) |

## 4. Configuración completa de cada interfaz

| Equipo | Interfaz | Adaptador VBox | IP / máscara | Puerta de enlace | DNS | MAC |
|---|---|---|---|---|---|---|
| R1-MikroTik-CHR | ether1-WAN | 1 · NAT | 10.0.2.15 / 255.255.255.0 | 10.0.2.2 | 172.16.222.1 | — |
| R1-MikroTik-CHR | ether2-LAN | 2 · LAN_G3 | 192.168.30.1 / 255.255.255.0 | — | — | — |
| R2-OPNsense | em0 (WAN) | 1 · NAT | 10.0.2.15 / 255.255.255.0 | 10.0.2.2 | 172.16.222.1 | 08:00:27:4c:ea:24 |
| R2-OPNsense | em1 (LAN) | 2 · LAN_G3 | 192.168.30.2 / 255.255.255.0 | — | — | 08:00:27:46:18:09 |
| R3-Debian-nftables | enp0s3 (WAN) | 1 · NAT | 10.0.2.15 / 255.255.255.0 | 10.0.2.2 | 172.16.222.1 | — |
| R3-Debian-nftables | enp0s8 (LAN) | 2 · LAN_G3 | 192.168.30.3 / 255.255.255.0 | — | — | — |

Los equipos internos usarán como puerta de enlace **`192.168.30.1`** (MikroTik), según el esquema
del grupo. OPNsense (`.2`) y Debian (`.3`) son alternativas: basta con cambiar la puerta de enlace
del cliente para que su tráfico pase por otro router.

> ⚠️ `172.16.222.1` es el DNS del centro y fuera del aula no responde. Allí hay que usar `10.0.2.3`.

## 5. Camino del tráfico

Un cliente de la LAN que navega por Internet hace este recorrido:

```
Cliente 192.168.30.x ──LAN_G3──▶ Router .1/.2/.3 ──(NAT: origen → 10.0.2.15)──▶ NAT VirtualBox 10.0.2.2
    ──(NAT del anfitrión)──▶ red del aula / casa ──▶ Internet
```

Hay **dos NAT encadenados**: el del router y el de VirtualBox.

Por qué la LAN queda aislada:
- `LAN_G3` es una red interna de VirtualBox y el anfitrión no tiene interfaz en ella.
- La única salida posible es atravesar un router.
- Si los tres routers están apagados, no hay ningún camino hacia fuera.

Verificación de cada router: [06-servidores-comunicaciones.md § Verificación](06-servidores-comunicaciones.md#5-verificación).
