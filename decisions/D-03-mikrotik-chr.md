# D-03 · MikroTik en versión CHR (VM) en lugar del hEX físico

- **Necesidad:** tener el router MikroTik del diseño sin disponer de un hEX en casa.
- **Opciones consideradas:** ISO de RouterOS para x86, imagen CHR (*Cloud Hosted Router*) o no tener MikroTik.
- **Criterios:** que funcione en VirtualBox, que no caduque y que sea el mismo RouterOS 7 que en clase.
- **Fuentes y pruebas:** web oficial de MikroTik (descargas y licencias CHR). La ISO x86 sin licencia es una demo de 24 h; la CHR gratuita no caduca.
- **Opción escogida:** CHR 7.24.5 en VDI, 256 MB de RAM.
- **Limitaciones aceptadas:** la licencia gratuita limita la subida a **1 Mbit/s por interfaz**. Medido: ~115 kB/s al actualizar los nodos ([I-03](../incidencies/I-03-descargas-lentas-por-r1.md)).
- **Qué obligaría a revisarla:** necesitar el rendimiento real del router (pruebas de la Tasca 7 a través de R1).
- **Uso de IA (si lo hubo):** Claude explicó la diferencia entre la ISO x86 y la CHR; la elección fue mía.
