# I-08 · Nuestra propia regla de DNS impide comprobar actualizaciones en casa

- **Síntoma:** TrueNAS devuelve `Connection timeout while fetching update manifest`, aunque se le ha puesto `10.0.2.3` como segundo DNS.
- **Impacto:** no se podía comprobar si había versión nueva del NAS.
- **Hipótesis:** (1) el servidor de actualizaciones no responde; (2) algo de nuestra red corta la consulta DNS.
- **Prueba que las distingue:** la regla de R1 *«Tasca 5: DNS externo bloqueado»* descarta todo el DNS de la LAN que no vaya a `172.16.222.1`, y `10.0.2.3` no es ese. Con la regla desactivada, la consulta funciona al momento. Es la hipótesis 2.
- **Acción:** se desactivó la regla solo durante la comprobación y se volvió a activar. Para actualizar los nodos Proxmox por R3 se añadió en R3 una excepción **temporal** (`nft insert`, no se guarda en el fichero) para `10.0.2.3`, y se quitó al acabar.
- **Resultado:** TrueNAS muestra 25.10.8 disponible ([t5-actualizaciones](../evidencies/t5-actualizaciones-20261121.txt)).
- **Retorno:** regla de R1 activa otra vez; la excepción de R3 se quitó recargando `/etc/nftables.conf`.
- **Medida para evitar que se repita:** es lo mismo que le pasó al grupo con su regla de HTTP: una regla de bloqueo afecta también a los servidores. En el aula no pasa, porque el DNS permitido es el del centro.
