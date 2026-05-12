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
cd midolec-v6
gh auth login
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/install_freeling_resources.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
```

`patch_freeling_rpath.sh` configura `_pyfreeling.so` y las librerias nativas
para que resuelvan `runtime/freeling/lib/` mediante RPATH/RUNPATH. Despues de
ese paso, no hace falta exportar `LD_LIBRARY_PATH` manualmente en cada terminal.

## spaCy

El backend ingles necesita:

- `spacy`;
- `pyphen`;
- modelo `en_core_web_sm`.

Instalacion:

```bash
cd midolec-v6
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
