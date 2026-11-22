# D-01 · La WAN de los routers sale por el NAT de VirtualBox

- **Necesidad:** que los tres routers tengan salida a Internet tanto en el PC de clase como en el de casa, con el mismo disco y sin reconfigurar nada.
- **Opciones consideradas:** adaptador puente con la tarjeta física (como el grupo, con una NIC USB), red NAT de VirtualBox compartida, o NAT por VM.
- **Criterios:** funcionar igual en las dos redes, no exponer las VM a la red del aula y no depender de IP que asigne el profesorado.
- **Fuentes y pruebas:** manual de VirtualBox, capítulo de redes (modo NAT: la VM recibe 10.0.2.15 y la puerta de enlace es 10.0.2.2). Comprobado en los tres routers el 17/11 ([05-installacions § 4.3](../docs/05-installacions.md#43-red-wan-y-lan-e-internet-desde-la-lan)).
- **Opción escogida:** NAT por VM, en el adaptador 1 de cada router. Cada VM tiene su propio motor NAT, así que las tres usan `10.0.2.15` sin chocar.
- **Limitaciones aceptadas:** hay dos NAT seguidos (el del router y el de VirtualBox); el traceroute no enseña los saltos de fuera ([04-disseny § 7.3](../docs/04-disseny.md#73-traceroute)); para gestionar un router desde el anfitrión hace falta reenviar puertos, solo en `127.0.0.1`.
- **Qué obligaría a revisarla:** tener que recibir conexiones desde la red del aula (por ejemplo, una VPN de los comerciales).
- **Uso de IA (si lo hubo):** Claude propuso el NAT por VM; se comprobó en las dos redes con ping y HTTP y se mantuvo.
