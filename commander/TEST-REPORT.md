# Informe de pruebas — 0.1.0~rc2

Entorno: Debian 13.7 AMD64, GTK 4.18.6, libadwaita 1.7.6, Meson 1.7.0. Base: Nautilus Debian 48.3-2, firma del descriptor verificada con la clave Debian 7A073AD1AE694FA25BFF62E5235C099D3EB33076.

## Resultados observados

- Compilación debug y debugoptimized: correctas.
- Batería original sin la prueba del indexador: 17 aprobadas, 0 fallos, 0 tiempos excedidos. Incluye archivos, metadatos, copia, movimiento, borrado y búsqueda simple.
- Prueba original del indexador: aprobada usando un índice temporal y archivo fuera de /tmp. LocalSearch excluye /tmp.
- Integración de ventana real: aprobada. Comprueba dos slots independientes, navegación a dos carpetas, conservación de ubicaciones y panel activo tras F3, pestañas, cierre de pestaña y cierre del panel activo. También copia y mueve datos con el motor original, comprobando contenido y existencia de origen/destino.
- Prueba con teclado y ratón en Xvfb: navegación del panel derecho a otra carpeta, F3, creación y cierre de pestañas, y cierre del panel derecho con conservación del izquierdo: aprobada en una ejecución tras corregir restauración de foco y destino de la barra de ubicación; una repetición posterior volvió a fallar al navegar. La prueba de teclado sigue siendo inconsistente y requiere diagnóstico antes de declarar la interfaz estable.
- Convivencia: se observaron dos ventanas y dos propietarios D-Bus distintos; org.freedesktop.FileManager1 permaneció en Nautilus original. Repetido con la aplicación extraída del paquete.
- Paquete: estructura Debian y dependencias válidas; apt simuló instalarlo sin actualizar ni quitar otros paquetes. Archivos sin coincidencias con archivos de paquetes instalados. El ejecutable resolvió todas sus bibliotecas.
- Instalación y eliminación mediante dpkg: aprobadas dentro de una raíz temporal, con espacio de usuarios separado y sin ejecutar los triggers globales del equipo. No equivale a una instalación en el escritorio real.

La prueba ampliada de Tab y portapapeles no llegó a completarse porque su paso previo de navegación falló. No se declara aprobada.

## Límites y pruebas pendientes

No se comprobó una sesión interactiva real de XFCE ni Wayland, arrastre entre paneles, unidades extraíbles, permisos restringidos, enlaces complejos, transferencias entre dispositivos, cancelación de transferencias grandes ni comparativas de rendimiento. Las búsquedas simultáneas desde ambas interfaces requieren verificación adicional. Las pruebas del motor de búsqueda original no sustituyen esas comprobaciones.

En sesiones virtuales se observaron avisos de FUSE, portales, directorios XDG y servicios de red no disponibles. Las pruebas del indexador usan su propia sesión y configuración, y pasaron. No se modificaron asociaciones MIME, servicios del escritorio ni paquetes del sistema anfitrión.

Este paquete es un candidato de desarrollo, no una versión estable con todos los criterios de aceptación satisfechos. Las limitaciones anteriores impiden certificar todavía la versión 0.1.0 final.

- En rc2 se probó la acción de terminal en cada uno de los dos paneles con una terminal de prueba que registró el directorio inicial; ambos coincidieron con sus carpetas. La acción para una carpeta seleccionada usa el mismo mecanismo.
