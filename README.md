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

All code, textures, and schematic files were created by koatl (tuxmatic) and are distributed under the MIT License. 

Audio files (Gregorian chants, polyphony, and bell sounds) are distributed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License. Please see the `LICENSE` file in this repository for full authorship credits, source links, and license terms.

# Latin Cross Basilica (exploration_catholic_church)

An architectural generation mod for Luanti (formerly Minetest) designed to showcase the majesty of Vatican and Catholic Church architecture in an interactive and fun way.

The primary goal is to allow players to explore the engineering of a monumental Latin cross floor plan, interact with its acoustics, and access a rich catalog of sacred art textures and materials (marble, bronze, stained glass, mahogany) that can be reused in any personal project or fortress.

## Key Features

* **Dynamic Algorithmic Generation:** Builds the church block-by-block before your eyes using chat commands. Powered by the "Tuxmatic Algorithm," the mod offloads thermal and lighting processing to the C++ engine, maintaining a 0% processing impact while idle.
* **Mutual Exclusion Acoustics:** Features dynamic proximity detection that plays Gregorian chants near the High Altar and polyphonic music near the pipe organ, intelligently muting the more distant source to avoid overloading audio threads.
* **Structural Ecosystems:** Generates authentic architectural modules such as the Narthex, Clerestory, Triforium, recessed confessionals, an interactive 95-meter-tall bell tower, and an underground crypt with sarcophagi.
* **Universal Deployment (Schematics):** Full support for packaging the structure into `.mts` binary files and instantly deploying them on any terrain.
* **Internationalization (i18n):** Natively translated into 10 languages ​​(English, Spanish, Italian, Portuguese, French, Japanese, Chinese, Russian, Korean, and Filipino) with full ContentDB standardization. ## Installation

1. Download the repository or the `.zip` file.
2. Extract the folder and rename it to `exploration_catholic_church`.
3. Move the folder to the `mods/` directory of your Luanti installation.
4. Enable the mod in your world settings.

## Main Commands

To experience the iterative construction process, position yourself on flat terrain and use the chat console:

* `/construir_nave` - Anchors the survey datum in memory and clears the terrain.
* `/construir_muros` - Raises the perimeter walls, triforium, and clerestory in a single mathematical pass.
* `/construir_boveda` - Erects the Renaissance barrel vault and suspends the main light fixtures.
* `/construir_crucero_cupula` - Generates the transept, the drum, and the central golden dome at a height of 65 meters.
* `/construir_cripta` - Excavates the underground area to create the papal reliquary zone.
* `/construir_campanario` - Raises an interactive 95-meter-tall bell tower with a spiral staircase.
* `/iluminar_interseccion` - Deploys high-performance static lighting.
* `/inventario_sacro` - Stocks your inventory with a stack of each block and texture for free use.
* `/exportar_basilica` / `/importar_basilica` - Manages binary `.mts` schematics for map portability.

## Contribution and Open Source

This project follows a free software philosophy. All code flows from low-level Lua logic to GitHub and finally to the ContentDB catalog. Feel free to fork the project, propose improvements via Pull Requests, or use the textures for your own mods.

## License

This project is licensed under the MIT License.

## Credits and Attribution

All code, textures, and schematic files were created by koatl (tuxmatic) and are distributed under the MIT License. 

Audio files (Gregorian chants, polyphony, and bell sounds) are distributed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License. Please see the `LICENSE` file in this repository for full authorship credits, source links, and license terms.