# Registro de uso de IA

Parte individual · Grupo 3 · Herramienta: **Claude** (asistente de IA de Anthropic), del 17 al 22/11/2026.

> Lo pide el enunciado en «Pensar i aportar criteri propi»: escribir una predicción **antes** de consultar la IA
> ([00-prediccions](00-prediccions.md), del 29/10/2026), registrar las propuestas relevantes, **cómo se contrastaron**
> y qué se **mantuvo, cambió o descartó**, y explicar una decisión que una respuesta genérica no resolvía.

## 1. Para qué se ha usado y para qué no

| | Quién |
|---|---|
| Diseño del entorno, alcance y decisiones (D-01 a D-09) | **Yo**. La IA propuso alternativas en algunas; se indica en cada ficha |
| Instalación y montaje de las máquinas virtuales | **Yo** |
| Órdenes en las VMs durante las pruebas de las Tareas 5 a 7 (copias, fallos de los routers, RAID, iSCSI, medidas) | La IA las ejecutó **a petición mía**, desde el anfitrión; yo revisé los resultados |
| Redacción de la documentación del repositorio y los PDF de entrega | La IA, a partir de las salidas reales (evidencias) y con mis correcciones |
| Predicciones iniciales | **Yo**, sin IA |

No se han introducido credenciales ni datos personales en las consultas. Las contraseñas están fuera del repositorio.

## 2. Propuestas de la IA: cómo se contrastaron y qué se decidió

| # | Propuesta de la IA | Cómo se contrastó | Decisión | Dónde |
|---|---|---|---|---|
| 1 | Dar IP por DHCP a los clientes | El diseño del grupo usa IP fijas por rangos | ❌ **Descartada**: todo manual, sin DHCP dentro de la empresa | [D-02](../decisions/D-02-sin-dhcp.md) |
| 2 | Poner los servidores Debian dentro del clúster Proxmox | La RAM medida en la Tasca 0: no cabe en 16 GB | ❌ **Descartada**: clúster vacío; los servidores, en el grupo | [D-04](../decisions/D-04-cluster-anidado-vacio.md) |
| 3 | Salida a Internet de los routers por el NAT de VirtualBox | `ping` y HTTP en casa y en el aula | ✅ **Mantenida** | [D-01](../decisions/D-01-wan-por-nat.md) |
| 4 | Crear las reglas de OPNsense en la sección clásica de `config.xml` | La prueba desde el cliente: el tráfico que debía bloquearse **seguía pasando** | 🔄 **Cambiada**: las reglas se crearon en el modelo nuevo, que se evalúa antes | [I-06](../incidencies/I-06-opnsense-orden-reglas.md) |
| 5 | Copiar `/etc/pve` entero de los nodos Proxmox | Revisión del contenido de la primera copia: llevaba **claves privadas** del clúster | 🔄 **Cambiada**: exclusiones en el script y copias borradas del NAS | [05 § 3.3](05-installacions.md#33-espacio-de-copias-en-truenas-qué-cómo-y-dónde) |
| 6 | Reiniciar los equipos con un reinicio en segundo plano por SSH | `uptime`: el reinicio **no se hacía** al cerrar la sesión (OPNsense quedó a medio actualizar) | 🔄 **Cambiada**: `systemd-run` o la consola | [I-07](../incidencies/I-07-opnsense-ssh-tras-actualizar.md) |
| 7 | Una regla de R1 que bloquea el DNS externo | Después bloqueó las actualizaciones del NAS | ✅ **Mantenida**, desactivándola solo mientras se actualiza | [I-08](../incidencies/I-08-regla-dns-bloquea-actualizaciones.md) |
| 8 | Medir la RAM de cada VM con la memoria del proceso VirtualBox | No cuadraba con la RAM disponible del PC: el NAS marcaba 866 MB y ocupaba ~2,9 GB | 🔄 **Cambiada**: diferencia de RAM disponible al encender o apagar cada VM | [07 § 2](07-rendiment.md#2-cómo-se-ha-medido) |
| 9 | Velocidades de RAID con `dd` | La primera medida daba «0 GB/s» (coma decimal y ceros) y los discos virtuales comparten el disco físico | 🔄 **Cambiada** la medida, y el resultado se presenta como **no representativo** | [06 § 3](06-recuperacio.md#3-tres-tipos-de-raid-creación-y-verificación) |
| 10 | Dar por cubierta la migración de Proxmox (a235/a236) con el trabajo de grupo | Texto literal de la rúbrica: «Proxmox individual» | Lo decidí yo: se mantiene en el grupo, porque el reparto de la rúbrica es un error | [D-04](../decisions/D-04-cluster-anidado-vacio.md) |
| 11 | Subir W11 a 25H2 con la ISO de la actividad | `sources/idwbinfo.txt` de la ISO: es la rama 22H2/23H2 | ❌ **Descartada**: no se puede con esa imagen; queda documentado | [I-10](../incidencies/I-10-w11-acumulativa-0x800f0991.md) |
| 12 | Bajar la RAM de los nodos Proxmox para optimizar | `free` y `vmstat` dentro de los nodos: usan 1,22 de 1,46 GB y ya hacen swap | ❌ **Descartada** | [07 § 6.2](07-rendiment.md#62-optimización-2-r3-saturaba-su-cpu-al-enrutar) |
| 13 | Provocar a propósito la falta de RAM para ver la saturación | El riesgo de colgar el PC, que no podía pasar | ❌ **Descartada**: el límite se da con lo medido | [07 § 4](07-rendiment.md#4-qué-satura-cada-máquina-virtual) |

## 3. Errores de la IA que hay que tener en cuenta

- **WS2025 (I-09).** El servidor no arrancaba y se reinstalaba solo desde el disco de la instalación desatendida. La IA
  lo apagó a mitad de esa reinstalación sin haber entendido aún qué pasaba. El disco ya no arrancaba antes, así que no
  se perdió nada, pero lo correcto era observar primero. Se reinstaló y se quitaron los medios de instalación de las
  dos Windows ([I-09](../incidencies/I-09-ws2025-reinstalacion-sola.md)).
- **Predicciones redactadas por la IA.** Las de las Tareas 6 y 7 las redactó la IA, y la de la 7 contradecía la
  Tasca 2. Se detectó en la revisión final y se corrigió.
- **Datos sin base.** En la Tasca 6 apareció una cifra de RAM (6,2 GB) que no salía de ninguna medida. Se corrigió
  con el método de la Tasca 7 (5,6 GB).

## 4. Una decisión que una respuesta genérica no resolvía

**La tarjeta de red de R3 (Tasca 7).** La respuesta genérica es que la tarjeta **virtio** (paravirtualizada) es la
más eficiente, y R3 la usaba.

La evidencia decía otra cosa:
- R3 solo pasaba **150–169 Mb/s** y gastaba hasta el **251 %** de un hilo del PC.
- R2, en el mismo PC y con la tarjeta Intel emulada, pasaba **614 Mb/s**.

Al cambiar R3 a la Intel 82540EM pasó a **~700 Mb/s** con una quinta parte de CPU. Lo que resolvió la duda fue
**medir antes y después en las mismas condiciones**, no la recomendación general
([t7-optimizaciones](../evidencies/t7-optimizaciones-antes-despues-20261122.txt)).

**Otra:** con la ISO de la actividad no se podía subir W11 de versión. Una respuesta genérica («actualiza a 25H2») no
sirve sin mirar qué imagen tenemos de verdad.
