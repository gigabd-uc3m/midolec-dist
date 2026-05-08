# Dependencias runtime

Las dependencias runtime son necesarias para ejecutar Midolec, pero no forman
parte del codigo fuente del proyecto.

## FreeLing

El backend espanol necesita:

- librerias nativas en `runtime/freeling/lib/`;
- recursos linguisticos en `runtime/freeling/share/freeling/common/`;
- recursos linguisticos en `runtime/freeling/share/freeling/es/`.

Instalacion:

```bash
gh auth login
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/install_freeling_resources.sh
```

Despues hay que definir:

```bash
export LD_LIBRARY_PATH="$PWD/runtime/freeling/lib:${LD_LIBRARY_PATH:-}"
```

## spaCy

El backend ingles necesita:

- `spacy`;
- `pyphen`;
- modelo `en_core_web_sm`.

Instalacion:

```bash
bash runtime/provisioning/install_spacy_en.sh
```

## GitHub CLI

Como el repositorio es privado, los scripts que descargan assets desde Releases
usan GitHub CLI:

```bash
gh auth login
gh auth status
```

La cuenta autenticada debe tener acceso al repositorio de distribucion.
