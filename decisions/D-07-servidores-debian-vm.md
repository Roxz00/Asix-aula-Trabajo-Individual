# D-07 · Los Debian de servicios y datos, como VM (se montan en el grupo)

- **Necesidad:** decidir si los servidores Debian `.22` y `.23` van en máquinas virtuales o en contenedores.
- **Opciones consideradas:** VM o contenedor LXC.
- **Criterios:** tipo de servidor. Es un servidor de datos con **muchos servicios distintos**, cada uno con necesidades de recursos diferentes.
- **Fuentes y pruebas:** documentación de Proxmox sobre VM y contenedores; comparación del grupo en su Tasca 5.
- **Opción escogida:** **VM** para los dos. Una VM tiene su propio núcleo, sus recursos y discos asignados por separado, y se copia y se migra entera. Un contenedor lo elegiría para un servicio único y ligero (por ejemplo, un WordPress). Los dos servidores se instalan en el trabajo de grupo, no en mi entorno ([D-04](D-04-cluster-anidado-vacio.md)).
- **Limitaciones aceptadas:** más RAM y disco que un contenedor.
- **Qué obligaría a revisarla:** que alguno de los servidores quedara con un solo servicio ligero.
- **Uso de IA (si lo hubo):** Claude explicó la diferencia VM/LXC; la decisión y el motivo son míos.
