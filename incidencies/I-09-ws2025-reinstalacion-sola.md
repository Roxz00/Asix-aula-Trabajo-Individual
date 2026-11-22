# I-09 · WS2025 no arranca y se pone a reinstalarse solo

- **Síntoma:** al encender WS2025 (21/11, 23:19) aparece «Instalación de Windows Server · 28 % completado» en lugar del inicio de sesión. Al apagarlo y volver a encender sin el DVD, el firmware muestra `failed to load Boot0003 "Windows Boot Manager" ... \EFI\Microsoft\Boot\bootmgfw.efi: Not Found` y `No bootable option or device was found`.
- **Impacto:** el servidor que centraliza el dominio no estaba disponible y su instalación del 19/11 se perdió (no tenía datos ni roles, solo la instalación base y la IP).
- **Hipótesis:** (1) se había vuelto a conectar la ISO de instalación por error; (2) el disco ya no arrancaba y el firmware pasó al siguiente medio de arranque.
- **Prueba que las distingue:**
  - La ISO `w2k25.iso` **no** estaba conectada. En el puerto SATA 1 seguía el disco auxiliar de la instalación desatendida (`Unattended-…-aux-iso.viso`), que VirtualBox construye a partir de la ISO y **es arrancable sin pedir ninguna tecla**.
  - En `VBox.log` se ve que a los 3 s se cargó `cdboot_noprompt.efi`: el disco no arrancó y el firmware pasó al DVD. Es la hipótesis 2.
  - La VM solo se había encendido una vez, el día de la instalación, y aquella sesión acabó como **«abortada»** porque se apagó el PC mientras Windows se cerraba (ver [00-entorno-pruebas](../docs/00-entorno-pruebas.md)). Ese corte es la causa más probable de que se dañara el arranque.
  - El instalador, con `autounattend.xml`, empezó a reparticionar el disco por su cuenta. Al apagar la VM a los 2 min de instalación ya no quedaba la instalación anterior.
- **Acción:** se volvió a conectar el disco auxiliar y se dejó terminar **la misma instalación desatendida** del 19/11 (misma edición, usuario `asix` y `VBOXPOST.CMD` con la IP fija `.21`). En la pregunta «continuar la actualización o instalación limpia» se eligió instalación limpia. Al acabar **se quitó el disco auxiliar**.
- **Resultado:** escritorio a las 23:30, unos **8 min** después de empezar. IP `.21`, puerta de enlace y DNS correctos, comprobados en la consola. Después se hizo la copia de la configuración en el NAS y se actualizó (26100.33438). Ver [05-installacions § 7](../docs/05-installacions.md#7-centralización-windows-server-2025).
- **Tiempo de respuesta:** detección 23:19 → servidor reinstalado 23:30 → copia en el NAS 23:34: unos **15 min** hasta tener el servidor como estaba y con copia.
- **Retorno:** a W11 (que también quedó «abortada» con su disco auxiliar puesto) se le quitó el disco auxiliar **antes** de encenderla, para que no le pudiera pasar lo mismo.
- **Medida para evitar que se repita:**
  1. Quitar siempre el medio de instalación en cuanto acaba la instalación desatendida.
  2. No apagar el PC con VMs de Windows cerrándose: apagarlas antes con `acpipowerbutton` y esperar a `poweroff`.
  3. Hacer una copia de la configuración (y, si cabe, una instantánea de la VM) nada más instalar.
