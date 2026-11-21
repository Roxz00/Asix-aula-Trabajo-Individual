# D-06 · Un cliente de cada tipo: W11 Pro y Debian con GNOME

- **Necesidad:** tener clientes Windows 11 y GNU/Linux, como pide el enunciado, sin pasar de 16 GB de RAM.
- **Opciones consideradas:** los 6 puestos del esquema del grupo, o uno de cada tipo.
- **Criterios:** cumplir el enunciado y caber en el escenario de servidores y clientes.
- **Fuentes y pruebas:** esquema del grupo (Dirección, Administración y Comercial con W11; Producción, Informática y portátil con Linux). Medido: W11 ocupa 4,3 GB y Debian ~1 GB ([00-entorno-pruebas § 8](../docs/00-entorno-pruebas.md#8-cuántas-máquinas-se-pueden-arrancar-a-la-vez)).
- **Opción escogida:** `CLI-W11-Direccion` (W11 **Pro**, porque Home no se puede unir a un dominio) en `.100` y `CLI-Debian-Produccion` (Debian 13 con su escritorio por defecto, GNOME) en `.101`.
- **Limitaciones aceptadas:** el W11 no está activado (clave genérica de instalación).
- **Qué obligaría a revisarla:** un departamento con necesidades distintas que hubiera que probar.
- **Uso de IA (si lo hubo):** Claude comprobó en el enunciado que los clientes son W11 y Linux; el reparto lo decidí yo.
