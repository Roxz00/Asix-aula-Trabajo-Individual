# D-04 · Clúster Proxmox de 3 nodos anidados y vacíos

- **Necesidad:** simular el clúster de 3 nodos del diseño dentro de un solo PC.
- **Opciones consideradas:** dejar el clúster solo como diseño, un único nodo, o 3 nodos en VirtualBox con virtualización anidada.
- **Criterios:** que el clúster exista de verdad (quórum incluido), que quepa en 16 GB de RAM y que no duplique el trabajo del grupo.
- **Fuentes y pruebas:** enunciado (*"si no hi ha prou nodes, el clúster quedarà com a disseny o simulació identificada"*); el i7-8700 de casa tiene VT-x + EPT. Prueba de quórum hecha ([t5-proxmox-prueba-quorum](../evidencies/t5-proxmox-prueba-quorum-20261119.txt)).
- **Opción escogida:** 3 VMs con Proxmox VE 9.2 (`--nested-hw-virt on`), 1,5 GB cada una, unidas en `cluster-g3`, **sin ninguna VM ni contenedor dentro**. Los servidores virtuales y la migración se hacen en el grupo.
- **Limitaciones aceptadas:** no se puede probar la migración en el entorno individual; la virtualización anidada es lenta.
- **Qué obligaría a revisarla:** que hubiera que probar servicios dentro del clúster en casa.
- **Uso de IA (si lo hubo):** Claude propuso poner los Debian dentro del clúster; se descartó y se dejó vacío.
