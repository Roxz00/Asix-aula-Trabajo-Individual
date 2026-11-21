# I-01 · VirtualBox no arranca VMs en el PC de casa

- **Síntoma:** al arrancar el disco externo en el PC de casa, `VBoxManage` avisa *«The vboxdrv kernel module is not loaded»* y ninguna VM arranca. En el PC de clase, con el mismo disco, funciona.
- **Impacto:** todo el entorno parado en casa.
- **Hipótesis:** (1) el módulo no está compilado para el núcleo actual; (2) Secure Boot bloquea el módulo porque su firma no es de confianza en esta placa.
- **Prueba que las distingue:** `modinfo vboxdrv` muestra que el módulo **existe** para el núcleo 6.8.0-138 y está firmado con una clave local (MOK). `mokutil --sb-state` → *SecureBoot enabled*. La lista de claves registradas en esta placa no incluye esa MOK. Se descarta la hipótesis 1: es la 2.
- **Acción:** `sudo mokutil --import /var/lib/shim-signed/mok/MOK.der`, reiniciar y, en el MOK Manager, *Enroll MOK → Continue → Yes*.
- **Resultado:** `mokutil --test-key` → *is already enrolled*; `vboxdrv`, `vboxnetflt` y `vboxnetadp` cargados; R1 arranca y se apaga bien.
- **Retorno:** no hace falta; la clave queda registrada en la placa de casa y Secure Boot sigue activado.
- **Medida para evitar que se repita:** el registro MOK se guarda en cada placa, no en el disco. Si el disco se usa en un tercer PC con Secure Boot, hay que repetir el registro (anotado en [02-inventari](../docs/02-inventari.md)).
