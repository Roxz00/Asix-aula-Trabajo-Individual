# 04 · Diseño físico y lógico

Tasca 4 «Disseny físic i lògic» · RA principales: FDM RA4; ISO RA1 y RA3 · **Parte individual**.

> Grupo 3 · Red interna `192.168.30.0/24` · Fechas: 17/11/2026 (diseño y montaje) y 21/11/2026 (verificación)

## 1. Qué pedía la Tasca 4 y dónde está

| Lo que se pide | Nivel | Dónde está | Estado |
|---|---|---|---|
| Dibujar el esquema de red individual, el montaje virtual y las direcciones previstas | Apte | Apartados 2 y 3 · [diagrames/](../diagrames/) | ✅ Hecho |
| Indicar la configuración de cada interfaz y la LAN 192.168.XX.0/24; la WAN por NAT | Apte | Apartados 3, 4 y 5 | ✅ Hecho |
| Implementar la red individual y comprobar la conectividad con ping, traceroute y tablas de rutas | Apte+ | Apartado 7 | ✅ Hecho |
| Aportar evidencias de ping, traceroute, tablas de rutas y configuración de las interfaces | Apte+ | Apartado 7 · [t4-conectividad](../evidencies/t4-conectividad-20261121.txt) | ✅ Hecho |

## 2. Esquemas

- **Esquema lógico individual (VirtualBox):** [diagrames/esquema-individual.md](../diagrames/esquema-individual.md)
- **Arquitectura de referencia del grupo:** [diagrames/arquitectura-referencia-grupo3.png](../diagrames/arquitectura-referencia-grupo3.png)

El entorno individual simula el del grupo, aunque no es una copia exacta (lo permite el enunciado).
La diferencia principal está en la WAN de los routers: en clase OPNsense y Debian salen en puente
por una NIC USB, mientras que aquí la WAN usa el **NAT de VirtualBox**.

## 3. Plan de direccionamiento

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
| Anfitrión | 192.168.30.15/24 | Manual | No se usa: en el entorno individual el anfitrión no tiene interfaz en `LAN_G3` (se gestiona saltando por R3) |
| NAS/SAN TrueNAS | 192.168.30.20/24 | Manual | ✅ |
| VM Windows Server 2025 (fuera del clúster) | 192.168.30.21/24 | Manual | ✅ |
| VM Debian · servicios | 192.168.30.22/24 | Manual | Solo en el grupo |
| VM Debian · datos | 192.168.30.23/24 | Manual | Solo en el grupo |
| Nodos Proxmox VE 1 / 2 / 3 | 192.168.30.32 / .33 / .34 /24 | Manual | ✅ (clúster vacío) |
| Cliente W11 · Dirección | 192.168.30.100/24 | Manual | ✅ |
| Cliente Debian GNOME · Producción | 192.168.30.101/24 | Manual | ✅ |
| Resto de clientes del grupo (Administración, Comercial, Informática, portátil) | .102 – .200 | Manual | No se montan en el entorno individual |

### Método de asignación: todo manual, sin DHCP

Dentro de la empresa **no hay ningún servidor DHCP**: ni los routers ni los servidores reparten
direcciones, y todas las IPs internas se configuran a mano. El único DHCP es el externo (el router
de casa o el servidor DHCP del centro), que da IP al anfitrión.

Así se cumple la norma del enunciado de no lanzar un DHCP de pruebas sobre la red compartida.
Además, cada equipo tiene siempre la misma IP, lo que facilita las reglas de cortafuegos y las copias.

## 4. Montaje en VirtualBox

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

## 5. Configuración completa de cada interfaz

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

## 6. Camino del tráfico

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

Verificación de cada router: [05-installacions.md § 4.3](05-installacions.md#43-red-wan-y-lan-e-internet-desde-la-lan).

## 7. Verificación de la conectividad (Apte+)

> 21/11/2026, en el PC de casa · VMs encendidas: R1, R3 y el cliente Debian (`.101`) ·
> Evidencia completa: [evidencies/t4-conectividad-20261121.txt](../evidencies/t4-conectividad-20261121.txt).
> La verificación inicial de los tres routers (17/11) está en
> [05-installacions.md § 4.3](05-installacions.md#43-red-wan-y-lan-e-internet-desde-la-lan).

### 7.1 Tablas de rutas

| Equipo | Destino | Por dónde | Qué significa |
|---|---|---|---|
| Cliente `.101` | `192.168.30.0/24` | directamente por `enp0s3` | La LAN está conectada: no necesita router |
| Cliente `.101` | `default` (todo lo demás) | `192.168.30.1` (R1) | Todo lo que no es de la LAN va al MikroTik |
| R1-MikroTik | `192.168.30.0/24` | `ether2-LAN` | Ruta conectada de la LAN |
| R1-MikroTik | `10.0.2.0/24` | `ether1-WAN` | Ruta conectada de la WAN (NAT de VirtualBox) |
| R1-MikroTik | `0.0.0.0/0` | `10.0.2.2` | Por defecto, al motor NAT de VirtualBox. Además, `srcnat masquerade` en `ether1-WAN` |
| R3-Debian | `192.168.30.0/24` y `10.0.2.0/24` | `enp0s8` y `enp0s3` | Las dos redes conectadas. `ip_forward = 1`: reenvía entre ellas |
| R3-Debian | `default` | `10.0.2.2` | Igual que R1 |
| Anfitrión | `192.168.30.101` | `192.168.1.1` (el router de casa) | El anfitrión **no tiene ruta a la LAN**: lo manda a Internet y el ping falla (100 % de pérdidas). La LAN está aislada |

### 7.2 Ping

| Desde | Hacia | Resultado | Qué demuestra |
|---|---|---|---|
| Cliente `.101` | R1 `.1` | ✅ 0 % pérdidas · 0,6 ms | LAN correcta |
| Cliente `.101` | R2 `.2` | ❌ 100 % pérdidas | Esperado: OPNsense estaba **apagado** |
| Cliente `.101` | R3 `.3` | ✅ 0 % pérdidas · 0,9 ms | LAN correcta |
| Cliente `.101` | `1.1.1.1` (Internet) | ✅ 0 % pérdidas · 11,6 ms | Salida a Internet por R1 con doble NAT |
| R3 | Cliente `.101` | ✅ 0 % pérdidas | La LAN responde en los dos sentidos |
| R3 | `1.1.1.1` | ✅ 0 % pérdidas · 10,8 ms | R3 también tiene salida |
| Anfitrión | Cliente `.101` | ❌ 100 % pérdidas | **Aislamiento**: desde fuera no se llega a la LAN |

### 7.3 Traceroute

Se usó `traceroute -I` (ICMP) desde el cliente, primero por la puerta de enlace normal y después
forzando otro camino con una **ruta temporal** hacia R3:

```
# Camino normal (puerta de enlace .1)                # Ruta temporal: 1.0.0.1 por R3
$ ip route get 1.1.1.1                                $ sudo ip route add 1.0.0.1/32 via 192.168.30.3
1.1.1.1 via 192.168.30.1 dev enp0s3                   1.0.0.1 via 192.168.30.3 dev enp0s3
$ sudo traceroute -I -n 1.1.1.1                       $ sudo traceroute -I -n 1.0.0.1
 1  192.168.30.1  0.521 ms     ← R1                    1  192.168.30.3  0.319 ms     ← R3
 2  *                                                  2  *
 …  *                                                  …  *
12  1.1.1.1  10.775 ms         ← destino              10  1.0.0.1  10.893 ms        ← destino
                                                      $ sudo ip route del 1.0.0.1/32
```

**Interpretación:**
- **El primer salto demuestra el camino:** el tráfico sale por R1 o por R3 según la tabla de rutas del
  cliente. Basta con cambiar la puerta de enlace (o añadir una ruta) para usar otro router.
- **Los saltos intermedios salen como `*`:** el NAT de VirtualBox no reenvía los mensajes ICMP
  *«tiempo excedido»* de los routers de Internet. Desde dentro de la VM, el camino real entre el NAT y el
  destino queda oculto, y el número de salto en que aparece el destino no es significativo.
- R1 también lo confirma con `/tool traceroute 1.1.1.1`: 0 % de pérdidas y 10,1 ms.

### 7.4 Problema encontrado: el DNS fuera del aula

Desde casa, `getent hosts deb.debian.org` **falla** en el cliente, aunque el ping por IP funciona.
- **Causa:** todos los equipos usan como DNS `172.16.222.1`, el del centro. Esa dirección solo existe en
  la red del aula.
- **Cómo se distingue de un fallo de red:** el ping a `1.1.1.1` por IP sí responde, así que el
  encaminamiento y el NAT funcionan. Lo único que falla es la resolución de nombres.
- **Solución en casa, si hace falta:** usar en los clientes un DNS público (por ejemplo `1.1.1.1`) o
  hacer que R1 resuelva (`/ip dns set servers=10.0.2.3 allow-remote-requests=yes`) y poner `.1` como DNS
  de los clientes. En el aula no hace falta tocar nada. No se ha cambiado, para mantener el diseño del
  grupo.
