# 00 · Predicciones iniciales

PREDIU · se responde antes de buscar información y se revisa al final con las pruebas · **Parte individual**.

> El enunciado pide que **cada persona responda antes de buscar información**. Estas respuestas son
> mías y se revisarán al final, comparándolas con las pruebas que me hayan hecho cambiar de opinión.
> Fecha: 29 / 10 / 2026

## 1. ¿Qué sistema pondrías en…

**…un cliente?**

_Respuesta: Windows 11, porque es lo que conoce la mayoría de usuarios y lo que usan los programas de empresa. Para alguien técnico o un equipo viejo, una Linux como Ubuntu o Mint_

**…un servidor de datos?**

_Respuesta: Linux, probablemente Debian o Ubuntu Server, porque es estable, gratis y consume poco. Si la empresa usa usuarios de Windows, quizás Windows Server para el dominio._

**…un equipo de comunicaciones?**

_Respuesta: Un router de marca con su propio sistema, como Cisco o MikroTik. También se podría usar un Linux con iptables, pero creo que sería más difícil de mantener._

## 2. ¿Qué comprobarías en el hardware?

_Respuesta: Que la CPU y la RAM sean suficientes para el sistema, el espacio en disco y si es SSD o HDD, que la tarjeta de red funcione y que la BIOS tenga activada la virtualización si se van a usar máquinas virtuales. También la temperatura y que los discos no tengan errores._

## 3. ¿Qué pasaría si se pierde un disco?

_Respuesta: Se perderían los datos de ese disco y el sistema dejaría de arrancar si era el del sistema operativo. Para evitarlo haría copias de seguridad o pondría un RAID, que creo que ya sirve como copia._

---

## Revisión final (se rellena al acabar la actividad)

| Predicción | ¿Se mantiene? | Prueba o evidencia que lo confirma o lo cambia |
|---|---|---|
| Windows 11 en el cliente | Sí, con matices | La versión 23H2 se quedó sin soporte y la actualización acumulativa falló con 0x800F0991 (I-10). Hay que vigilar el ciclo de vida de la versión, no solo el sistema |
| Linux genérico en el servidor de datos | Cambia | Para datos es mejor un sistema hecho para ello, como TrueNAS con ZFS, instantáneas y recursos NFS/SMB (Tasca 5, `t5-copias-nas-20261121.txt`) |
| Router de marca mejor que un Linux | Cambia | R3 (Debian con nftables) se recuperó del fallo en 1 s, frente a 17 s de MikroTik y 57 s de OPNsense (`t5-routers-fallo-recuperacion-20261121.txt`) |
| Comprobaciones de hardware (CPU, RAM, disco, red, virtualización) | Sí | Inventario y tests de diagnóstico de la Tasca 2, y SHA256 de las imágenes en la Tasca 5 (`t5-sha256-imagenes-20261121.txt`) |
| Si se pierde un disco se pierden los datos | Cambia | Con RAID 1/5 el sistema sigue funcionando con un disco menos y se reconstruye al cambiarlo (Tasca 6) |
| El RAID sirve como copia de seguridad | No | El RAID solo protege de la avería de un disco: un borrado o un fallo de configuración se replica en todos los discos. Hace falta además la copia en el NAS (Tasca 5) y la prueba de la Tasca 6 |
