# D-09 · Espejo entre dos equipos: RAID 1 de mdadm con un disco iSCSI del NAS

- **Necesidad:** hacer el Apte+ de la Tasca 6, un RAID en espejo entre dos discos que estén en dos equipos
  distintos, dentro de los 16 GB de RAM del PC de casa.
- **Opciones consideradas:**
  1. mdadm en `deb-produccion` con un disco local y un disco iSCSI servido por TrueNAS.
  2. DRBD entre dos Debian.
  3. Réplica de ZFS (`zfs send/receive`) de TrueNAS a otro equipo.
  4. Ceph o GlusterFS.
  5. Storage Replica de Windows Server.
- **Criterios:**
  - Que sea un espejo **en tiempo real**, no una copia periódica.
  - Que quepa en la memoria con lo que ya está encendido.
  - Que se pueda comprobar quitando cada uno de los dos lados.
  - Que use sistemas que ya forman parte del entorno.
- **Fuentes y pruebas:** documentación de `mdadm(8)` (`--write-mostly`, `--bitmap`) y de `iscsiadm(8)`, y la API de
  TrueNAS 25.10 (iscsi/portal, initiator, target, extent, targetextent). Pruebas del 22/11/2026 en
  [t6-espejo-iscsi-dos-equipos](../evidencies/t6-espejo-iscsi-dos-equipos-20261122.txt).
- **Opción escogida:** **(1) mdadm + iSCSI.**
  - El NAS ya está encendido para las copias, así que no hace falta otra VM.
  - Es el mismo RAID 1 del Apte, solo que con uno de los discos en otro equipo.
  - El disco remoto va en `write-mostly`, con bitmap interno y con un `replacement_timeout` de 15 s.
  - Descartes: DRBD habría necesitado un segundo Debian solo para esto. La réplica de ZFS no es en tiempo real. Ceph
    pide 3 nodos con mucha RAM. Storage Replica necesita dos Windows Server.
- **Limitaciones aceptadas:**
  - Si el NAS cae, las escrituras se paran unos **20 s** antes de seguir con el disco local.
  - Solo un equipo puede usar el disco a la vez: no hay acceso compartido.
  - Los dos equipos son VMs del mismo PC: se demuestra el funcionamiento, no la protección frente a la avería del PC.
- **Qué obligaría a revisarla:** necesitar que otro equipo tome el servicio de forma automática (alta
  disponibilidad), lo que llevaría a DRBD con Pacemaker o a Ceph. También tener más de dos equipos con discos.
- **Uso de IA (si lo hubo):** Claude comparó las opciones y propuso usar el NAS que ya estaba encendido, por la
  limitación de memoria. También configuró el NAS y el cliente e hizo las pruebas. Los resultados se contrastaron
  con las salidas de `mdadm`, `iscsiadm` y la API de TrueNAS.
