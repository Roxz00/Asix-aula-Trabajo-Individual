# I-03 · Las descargas a través de R1 van a ~115 kB/s

- **Síntoma:** `apt-get update` en los nodos Proxmox tarda unos 1 min 30 s en bajar 10,7 MB (~115 kB/s). Con los Windows actualizando, el ping a R1 sube a ~100 ms con pérdidas.
- **Impacto:** instalar el cliente Debian con GNOME (~1.400 paquetes) por R1 habría tardado horas.
- **Hipótesis:** (1) la red de casa o del aula es lenta; (2) la licencia gratuita del CHR limita el caudal.
- **Prueba que las distingue:** desde el anfitrión, la misma red descarga a ~660 Mb/s ([t2-diagnostico](../evidencies/t2-diagnostico-pc-casa-20261121.txt)). 115 kB/s ≈ 1 Mbit/s, justo el límite de la licencia *free* de CHR. Es la hipótesis 2.
- **Acción:** para la instalación del cliente Debian, adaptador NAT temporal solo durante la instalación; después se dejó únicamente en `LAN_G3`.
- **Resultado:** instalación en ~35 min; el cliente quedó con IP manual `.101`.
- **Retorno:** adaptador NAT y reenvío de puerto temporales eliminados (comprobado con `showvminfo`).
- **Medida para evitar que se repita:** para descargas grandes, usar R2 o R3 como puerta de enlace, que no tienen límite.
