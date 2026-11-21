# I-04 · Los equipos de la LAN no resuelven nombres en casa

- **Síntoma:** en casa, `getent hosts deb.debian.org` falla en el cliente Debian, pero `ping 1.1.1.1` responde.
- **Impacto:** fuera del aula, los equipos de la LAN solo funcionan por IP.
- **Hipótesis:** (1) falla el encaminamiento o el NAT; (2) falla solo el DNS.
- **Prueba que las distingue:** el ping y el traceroute a `1.1.1.1` por IP funcionan por R1 y por R3 ([t4-conectividad](../evidencies/t4-conectividad-20261121.txt)), así que el encaminamiento está bien. El DNS configurado es `172.16.222.1`, que solo existe en la red del aula. Es la hipótesis 2.
- **Acción:** ninguna, para mantener el diseño del grupo (DNS del centro).
- **Resultado:** documentado en [04-disseny § 7.4](../docs/04-disseny.md#74-problema-encontrado-el-dns-fuera-del-aula).
- **Retorno:** —
- **Medida para evitar que se repita:** si hiciera falta en casa, poner R1 como DNS (`/ip dns set servers=10.0.2.3 allow-remote-requests=yes`) y `.1` en los clientes.
