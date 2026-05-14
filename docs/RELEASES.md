# Releases

Los binarios y recursos pesados deben publicarse como assets de GitHub Releases,
no como ficheros versionados en `main`.

Este documento describe como nombrar y preparar entregas internas o publicas de
Midolec. Para ejecutar una version ya descargada, consultar
`docs/GUIA_EJECUCION.md`. Para validar una entrega interna, consultar
`docs/VALIDACION_V6.md`.

## Convencion de versiones

Para V6, mientras siga siendo una version intermedia:

```text
v6.0.0-alpha.1
v6.0.0-alpha.2
v6.0.0-beta.1
```

Para versiones historicas cerradas, como V4.2:

```text
v4.2.0
```

## Assets recomendados

Cada Release deberia incluir:

- paquete ejecutable de Midolec;
- librerias FreeLing compatibles, si aplica;
- recursos FreeLing, si aplica;
- checksums `SHA256SUMS`;
- guia breve de ejecucion de esa version.

## Entrega interna actual de V6

Estado:

```text
Tipo: internal evaluation build
Source repo commit de referencia: 082b290
Distribution package commit de referencia: commit de la build con spacy/pyphen integrados
Runtime assets tag: v6-runtime-2026-05-07
Repositorio de assets: gigabd-uc3m/midolec-dist
```

El commit de distribucion indicado corresponde al paquete base compartido para
prueba interna. La documentacion de soporte puede tener commits posteriores.

La distribucion interna actual se organiza alrededor de:

```text
midolec-v6/
  midolec-v6
  _internal/
  midolecConfig.toml
  config/
  runtime/
    README.md
    provisioning/
```

Incluido en Git:

- binario PyInstaller `midolec-v6`;
- dependencias internas empaquetadas por PyInstaller en `_internal/`;
- configuracion TOML editable;
- scripts de provisioning;
- documentacion de ejecucion, configuracion, validacion y troubleshooting.

No incluido en Git:

- librerias nativas FreeLing descargables en `runtime/freeling/lib/`;
- recursos FreeLing descargables en `runtime/freeling/share/freeling/`;
- modelos spaCy descargables en `runtime/spacy/models/`;
- salidas JSON generadas por ejecuciones locales.

Assets runtime esperados:

```text
midolec-v6-freeling-libs-linux-x86_64-2026-05-07.tar.gz
midolec-v6-freeling-resources-es-2026-05-07.tar.gz
SHA256SUMS
```

Validacion minima antes de compartir una build interna:

```bash
cd midolec-v6
gh auth login
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/install_freeling_resources.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh
./midolec-v6 prueba_v6.txt
```

Criterio minimo:

- el binario arranca;
- no hace falta exportar `LD_LIBRARY_PATH`;
- FreeLing resuelve librerias mediante RPATH/RUNPATH;
- se genera un JSON de salida;
- no hay librerias nativas de FreeLing dentro de `_internal/`.

### Validacion WSL del 2026-05-13

Se ha realizado una validacion local en WSL sobre el codigo fuente V6 y sobre el
paquete de distribucion.

Resultados:

- Codigo fuente V6 en espanol: validado.
- Codigo fuente V6 en ingles: validado.
- Bateria `es-2026_juridica_avanzada`: 70/70 comprobaciones configuradas correctas.
- Bateria `es-2025_bateria_funcionalidades`: 120/120 comprobaciones configuradas correctas, 20 deshabilitadas.
- Bateria `en-2025_bateria_funcionalidades`: 200/200 comprobaciones configuradas correctas.
- Binario de distribucion en espanol: validado sin `LD_LIBRARY_PATH`.
- Binario de distribucion en ingles: validado tras reconstruir PyInstaller con `spacy` y `pyphen` dentro de `_internal/`.

Durante esta validacion se confirmo que la estrategia RPATH/RUNPATH funciona para
FreeLing en el binario de distribucion. Tambien se reconstruyo el ejecutable
para que el backend ingles pueda importar `spacy` y `pyphen` desde `_internal/`.
El modelo `en_core_web_sm` se mantiene fuera de Git como recurso runtime externo
en `runtime/spacy/models/`.

## Checklist para crear una nueva Release V6

1. Generar o actualizar el paquete `midolec-v6/`.
2. Comprobar que `_internal/` no contiene `libfreeling.so`, `libfoma.so`,
   `libtreeler.so`, `libdynet.so` ni `libcrfsuite.so`.
3. Comprobar que `runtime/freeling/` y `runtime/spacy/` no contienen assets
   descargados antes del commit.
4. Publicar o reutilizar los assets runtime versionados.
5. Ejecutar `docs/VALIDACION_V6.md`.
6. Actualizar este documento con commits, tag y observaciones.
7. Avisar a colaboradores de la version y del procedimiento de validacion.

## Limitaciones conocidas de la entrega interna

- La distribucion esta pensada para Linux/WSL.
- El backend espanol usa FreeLing y depende de assets runtime externos.
- El backend ingles con spaCy esta validado en la build actual, siempre que el
  modelo `en_core_web_sm` este instalado en `runtime/spacy/models/`.
- La publicacion externa requiere revisar licencias, especialmente por FreeLing.

## Publicacion futura

Antes de hacer publica una Release con FreeLing debe revisarse la compatibilidad
con AGPL y decidir si se publicara tambien el codigo fuente correspondiente.
