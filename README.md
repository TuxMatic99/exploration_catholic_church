# Basílica de Cruz Latina (exploration_catholic_church)

Un mod de generación arquitectónica para Luanti (anteriormente Minetest) diseñado para representar la majestuosidad de la arquitectura del Vaticano y la Iglesia Católica de una manera interactiva y divertida. 

El objetivo principal es permitir a los jugadores explorar la ingeniería de una planta de cruz latina monumental, interactuar con su acústica y proporcionar un rico catálogo de texturas y materiales de arte sacro (mármol, bronce, vitrales, caoba) que pueden ser reutilizados en cualquier proyecto personal o fortaleza.

## Características Principales

* **Generación Algorítmica Dinámica:** Construye la iglesia bloque a bloque frente a tus ojos utilizando comandos de chat. Impulsado por el "Algoritmo Tuxmatic", el mod delega el esfuerzo térmico y lumínico al motor C++ para mantener un impacto de procesamiento del 0% durante el reposo.
* **Acústica de Exclusión Mutua:** Incluye un radar de proximidad dinámico que reproduce cantos gregorianos cerca del Altar Mayor y música polifónica cerca del Órgano Tubular, silenciando de forma inteligente la fuente más lejana para no saturar los hilos de audio.
* **Ecosistemas Estructurales:** Genera módulos arquitectónicos reales como el Nártex, el Claristorio, el Triforio, Confesionarios empotrados, un Campanario interactivo de 95 metros de altura y una Cripta Subterránea con sarcófagos.
* **Despliegue Universal (Schematics):** Soporte total para empaquetar la obra en archivos binarios `.mts` y desplegarlos instantáneamente en cualquier terreno.
* **Internacionalización (i18n):** Traducido nativamente a 10 idiomas (Inglés, Español, Italiano, Portugués, Francés, Japonés, Chino, Ruso, Coreano y Filipino) con estandarización completa para ContentDB.

## Instalación

1. Descarga el repositorio o el archivo `.zip`.
2. Extrae la carpeta y renómbrala a `exploration_catholic_church`.
3. Mueve la carpeta al directorio `mods/` de tu instalación de Luanti.
4. Habilita el mod en la configuración de tu mundo.

## Comandos Principales

Para experimentar la construcción iterativa, ubícate en un terreno llano y utiliza la consola de chat:

* `/construir_nave` - Ancla el Datum topográfico en la memoria y despeja el terreno.
* `/construir_muros` - Levanta los muros perimetrales, el triforio y el claristorio en una pasada matemática.
* `/construir_boveda` - Erige la bóveda de cañón renacentista y suspende las luminarias mayores.
* `/construir_crucero_cupula` - Genera el transepto, el tambor y la cúpula dorada central a 65 metros.
* `/construir_cripta` - Excava el subsuelo para crear la zona de relicarios papales.
* `/construir_campanario` - Levanta una torre interactiva de 95 metros de altura con escalera de caracol.
* `/iluminar_interseccion` - Despliega iluminación estática de alto rendimiento.
* `/inventario_sacro` - Abastece tu mochila con un stack de cada bloque y textura para uso libre.
* `/exportar_basilica` / `/importar_basilica` - Manejo de esquemas binarios `.mts` para la portabilidad del mapa.

## Contribución y Código Abierto

Este proyecto sigue una filosofía de software libre. Todo el código fluye desde la lógica de bajo nivel en Lua hacia GitHub y finalmente al catálogo de ContentDB. Siéntete libre de bifurcar (fork), proponer mejoras a través de Pull Requests, o tomar las texturas para tus propios mods.

## Licencia

Este proyecto está bajo la Licencia MIT.

## Credits and Attribution

**Audio Files:**
* `exploration_catholic_church_gregoriano.ogg`: Gregorian chant audio sourced from @tuxmatic at (https://youtube.com/shorts/bbsD958lzzo?si=cnN_J--ULbYkUIl6). Licensed under CC BY 4.0.
* `exploration_catholic_church_polifonia.ogg`: Polyphony choral audio sourced from @tuxmatic at (https://youtube.com/shorts/ovnKw-c6-Ko?si=IPpKi-6KdyZiVV1z). Licensed under CC BY 4.0.
* `exploration_catholic_church_campana.ogg`: Bronze bell sound effect sourced from @prosoundsx at (https://youtu.be/HlVRji1lI-M). Licensed under CC BY 4.0.

All other code, textures, and schematic files were created by tuxmatic and are distributed under the MIT License.