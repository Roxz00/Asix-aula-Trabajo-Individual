# I-05 · OPNsense: «No bootable medium found»

- **Síntoma:** la VM de OPNsense no arranca y muestra *No bootable medium found*.
- **Impacto:** no se podía instalar R2.
- **Hipótesis:** (1) la imagen está dañada; (2) la BIOS arranca de otro disco.
- **Prueba que las distingue:** `opnsense.vdi` era la imagen *live* de instalación. La BIOS de VirtualBox arranca del disco del puerto SATA 0, donde estaba el disco de sistema vacío. Es la hipótesis 2.
- **Acción:** poner la imagen *live* en el puerto 0 para instalar sobre el disco de 10 GB y, después, dejar solo el disco de sistema.
- **Resultado:** OPNsense 26.7 instalado y arrancando ([t5-opnsense-instalacion-completada](../evidencies/t5-opnsense-instalacion-completada-20261117.png)).
- **Retorno:** la imagen *live* original no se modificó.
- **Medida para evitar que se repita:** revisar el orden de arranque y de los discos antes de instalar.
