# I-06 · OPNsense no aplica la regla de bloqueo añadida

- **Síntoma:** después de añadir en `config.xml` una regla que bloquea el DNS externo, el cliente sigue conectando con `8.8.8.8:53` a través de OPNsense, y en `/var/log/filter/latest.log` no aparece la regla.
- **Impacto:** la prueba de conexión bloqueada de OPNsense no salía.
- **Hipótesis:** (1) la regla no se ha cargado; (2) se ha cargado, pero otra regla coincide antes.
- **Prueba que las distingue:** `pfctl -sr` muestra la regla cargada (línea 74), pero **detrás** de `pass in quick on em1 ... label "019cd9b3-…"`, que es la regla por defecto *Default allow LAN to any*. Con `quick`, gana la primera que coincide. Es la hipótesis 2.
- **Causa:** en OPNsense 26 la regla por defecto de la LAN está en el **modelo nuevo de reglas** (`<OPNsense><Firewall><Filter>`), que se carga antes que las reglas clásicas (`<filter>`), que es donde se había puesto la nueva.
- **Acción:** se restauró la copia anterior de `config.xml` y se crearon las dos reglas en el modelo nuevo, con secuencia 10 y 20, delante de la regla por defecto (que pasa a 100).
- **Resultado:** `pfctl -sr` las muestra en el orden correcto y el registro muestra `block` para el DNS y `pass` para el HTTP ([t5-routers-permitida-bloqueada](../evidencies/t5-routers-permitida-bloqueada-20261121.txt)).
- **Retorno:** —
- **Medida para evitar que se repita:** comprobar siempre el orden real con `pfctl -sr` después de cambiar reglas.
