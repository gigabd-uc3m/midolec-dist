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
sudo apt update
sudo apt install -y curl patchelf libboost-regex1.74.0 libboost-program-options1.74.0
bash runtime/provisioning/install_configure_freeling.sh
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

## Descarga de assets

Los scripts descargan los assets desde la Release publica de GitHub mediante
`curl` o `wget`. GitHub CLI no es necesario para el flujo normal.

Si el repositorio vuelve a ser privado, los mismos scripts pueden usar GitHub
CLI como fallback tras ejecutar `gh auth login` en la misma terminal Ubuntu/WSL.
