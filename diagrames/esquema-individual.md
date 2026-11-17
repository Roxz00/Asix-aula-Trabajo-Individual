# Esquema lógico del entorno individual (VirtualBox)

Anfitrión: Linux Mint 22.3 en disco externo (se arranca en el PC de clase y en el de casa).

```mermaid
flowchart TB
    INET((Internet))
    EXT["Red externa del anfitrión<br/>aula 172.16.222.0/24 · casa: router doméstico<br/>(el único DHCP es este)"]
    INET --- EXT

    subgraph HOST["Anfitrión · Linux Mint 22.3 · VirtualBox 7.2"]
        direction TB
        NAT1["NAT VBox R1<br/>10.0.2.2"]
        NAT2["NAT VBox R2<br/>10.0.2.2"]
        NAT3["NAT VBox R3<br/>10.0.2.2"]

        R1["R1-MikroTik-CHR<br/>WAN ether1 10.0.2.15/24<br/>LAN ether2 192.168.30.1/24"]
        R2["R2-OPNsense<br/>WAN em0 10.0.2.15/24<br/>LAN em1 192.168.30.2/24"]
        R3["R3-Debian-nftables<br/>WAN enp0s3 10.0.2.15/24<br/>LAN enp0s8 192.168.30.3/24"]

        LAN{{"Red interna VirtualBox LAN_G3<br/>192.168.30.0/24 · sin DHCP"}}

        SRV["Servidores (pendiente)<br/>TrueNAS .20 · WS2025 .21<br/>Debian .22 / .23 · Proxmox .32-.34"]
        CLI["Clientes (pendiente)<br/>.100 – .200 · IP manual"]

        NAT1 --- R1
        NAT2 --- R2
        NAT3 --- R3
        R1 --- LAN
        R2 --- LAN
        R3 --- LAN
        LAN --- SRV
        LAN --- CLI
    end

    EXT --- NAT1
    EXT --- NAT2
    EXT --- NAT3
```

- Línea continua = enlace de red (adaptador virtual).
- Cada router tiene **su propio motor NAT**, por eso los tres comparten la IP WAN `10.0.2.15` sin conflicto.
- La red `LAN_G3` solo existe dentro de VirtualBox: si ningún router está encendido, la LAN no tiene salida.

Referencia del grupo: [arquitectura-referencia-grupo3.png](arquitectura-referencia-grupo3.png).
