# D-08 · Copias: configuración de cada equipo en el pool `copias` del NAS

- **Necesidad:** guardar en el servidor de copias lo necesario para recuperar cada equipo crítico, dentro de un pool de 20 GB y de los 16 GB de RAM de casa.
- **Opciones consideradas:** (1) imagen completa de cada VM (OVA o `vzdump`); (2) solo la configuración de cada equipo; (3) una mezcla de las dos.
- **Criterios:** espacio disponible (20 GB), tiempo de recuperación, que la copia se pueda automatizar y que no se guarden secretos en una carpeta de red sin necesidad.
- **Fuentes y pruebas:** tamaños medidos el 21/11/2026 ([t5-copias-nas](../evidencies/t5-copias-nas-20261121.txt)). Los discos de las VMs ocupan en el anfitrión unos **65 GB** (W11 14 GB, WS2025 14 GB, cada nodo Proxmox 5–6 GB, cliente Debian 7,5 GB): con las dos de Windows ya se llenaría el pool. Todas las configuraciones juntas ocupan **unos 2 MB** (2,4 MB contando las copias repetidas de las pruebas). Recuperación probada en los tres routers ([t5-routers-fallo-recuperacion](../evidencies/t5-routers-fallo-recuperacion-20261121.txt)).
- **Opción escogida:** **(3) mezcla**, con la configuración como copia principal:
  - **Configuración** de todos los equipos, en `copias/configuraciones` (cuota de 4 GB), una carpeta por equipo. Llega por **NFS** (Linux y Proxmox), **SFTP** (MikroTik y OPNsense) y **SMB** (Windows).
  - **Imagen** solo de la VM más pequeña y crítica, R1 (76 MB de disco), en `copias/imagenes` (cuota de 14 GB), para poder recuperarla sin reinstalar.
  - Las ISO no se copian: se vuelven a descargar y su SHA256 está anotado.
- **Limitaciones aceptadas:** para recuperar un equipo que no sea R1 hay que reinstalarlo desde la ISO (unos 10–35 min según el sistema) y después restaurar la configuración. Las copias y el NAS están en el mismo disco externo que todo el entorno: protegen de errores de configuración, no de que se rompa el disco.
- **Qué obligaría a revisarla:** que los servidores tuvieran datos de usuarios (entonces habría que copiar datos e imágenes) o disponer de un disco más grande para el pool.
- **Uso de IA (si lo hubo):** Claude midió los tamaños y propuso la mezcla; la decisión es mía.
