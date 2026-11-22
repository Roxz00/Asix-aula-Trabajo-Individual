# I-07 · OPNsense rechaza las contraseñas por SSH después de actualizar

- **Síntoma:** después de `opnsense-update -bk`, el SSH responde `Permission denied` con la contraseña correcta. En `/var/log/audit/latest.log` aparece `error: PAM: Authentication error`.
- **Impacto:** se perdió la gestión remota de OPNsense; había que trabajar desde la consola.
- **Hipótesis:** (1) se ha cambiado la contraseña o la configuración del SSH; (2) el sistema está a medio actualizar.
- **Prueba que las distingue:** en la consola, `freebsd-version -kru` da kernel **p1** en ejecución y sistema base **p6**: el reinicio programado no llegó a ejecutarse, porque se cortó al cerrarse la sesión SSH. Es la hipótesis 2: las bibliotecas nuevas de PAM no encajaban con el sistema en ejecución.
- **Acción:** reinicio desde la consola (`shutdown -r now`).
- **Resultado:** después del reinicio, el kernel y la base están en p6, OPNsense en 26.7.9_3 y el SSH funciona.
- **Retorno:** —
- **Medida para evitar que se repita:** reiniciar después de actualizar la base **desde la consola** o con la opción 12 del menú, no desde una sesión SSH que se va a cerrar.
