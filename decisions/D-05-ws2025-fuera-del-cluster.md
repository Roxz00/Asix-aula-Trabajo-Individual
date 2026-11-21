# D-05 · Windows Server 2025 fuera del clúster

- **Necesidad:** tener el controlador de dominio del diseño en el entorno individual.
- **Opciones consideradas:** VM dentro de un nodo Proxmox (anidada) o VM directa en VirtualBox.
- **Criterios:** rendimiento aceptable con 2 GB de RAM y no depender de que el clúster esté encendido.
- **Fuentes y pruebas:** requisitos de Windows Server 2025 (2 GB con escritorio, UEFI y TPM 2.0); instalado y comprobado el 19/11 ([t5-ws2025-verificacion-red](../evidencies/t5-ws2025-verificacion-red-20261119.png)).
- **Opción escogida:** VM de VirtualBox con EFI, TPM 2.0 y Secure Boot, IP `192.168.30.21`.
- **Limitaciones aceptadas:** no se puede migrar entre nodos; las copias se hacen desde VirtualBox, no con `vzdump`.
- **Qué obligaría a revisarla:** necesitar alta disponibilidad del dominio.
- **Uso de IA (si lo hubo):** decisión propia; Claude la aplicó.
