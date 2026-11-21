# D-02 · Ningún DHCP dentro de la empresa: todas las IP manuales

- **Necesidad:** dar IP a todos los equipos de `LAN_G3` sin romper la norma del enunciado de *no lanzar un DHCP de pruebas sobre la red compartida*.
- **Opciones consideradas:** DHCP en el MikroTik para los clientes (como el grupo), o todas las IP manuales.
- **Criterios:** que cada equipo tenga siempre la misma IP (reglas de cortafuegos y copias más sencillas) y que no haya ningún servidor DHCP que pueda escaparse a otra red.
- **Fuentes y pruebas:** enunciado, Tasca 4. Comprobado que los routers no tienen ningún servidor DHCP: MikroTik `/ip dhcp-server` vacío y nada escuchando en el puerto 67 en OPNsense ni en Debian.
- **Opción escogida:** todo manual. El único DHCP es el externo (router de casa o servidor del centro), que solo da IP al anfitrión.
- **Limitaciones aceptadas:** hay que configurar a mano cada equipo nuevo; los clientes no reciben el DNS automáticamente.
- **Qué obligaría a revisarla:** que hubiera muchos clientes o portátiles que cambien de red a menudo.
- **Uso de IA (si lo hubo):** Claude propuso al principio DHCP para los clientes; se descartó por decisión propia y se dejó todo manual.
