# Guia de configuracion

Midolec se configura mediante ficheros TOML editables.

## Configuracion global

`midolecConfig.toml` contiene opciones generales del programa:

- idioma por defecto;
- contexto por defecto;
- rutas runtime;
- flags globales de salida JSON;
- formato horario sugerido.

## Configuracion por idioma

La carpeta `config/` contiene opciones especificas por idioma:

- `config/es.toml`: backend FreeLing, segmentacion y flags de analisis espanol.
- `config/en.toml`: backend ingles y opciones especificas de ingles.

## Regla general

Las metricas se calculan internamente y las flags controlan principalmente que
bloques aparecen o desaparecen del JSON final. Esto evita mezclar la logica de
analisis con la logica de presentacion.

## Recomendacion para testers

Para probar cambios de configuracion, modifica una opcion cada vez y compara el
JSON generado antes y despues. Asi es mas facil detectar si una flag afecta al
bloque esperado.
