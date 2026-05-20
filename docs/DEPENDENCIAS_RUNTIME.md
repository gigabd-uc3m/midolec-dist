# Dependencias runtime

Las dependencias runtime son necesarias para ejecutar Midolec, pero no forman
parte del codigo fuente del proyecto.

## Instalacion recomendada

Para usuarios finales, usar el instalador guiado:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
```

El instalador pregunta que backend preparar, muestra una checklist
`OK/MISSING/WARN`, solicita confirmacion antes de instalar y termina con un
resumen. Para diagnosticar sin modificar nada:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend all
```

## FreeLing

El backend espanol necesita:

- librerias nativas en `runtime/freeling/lib/`;
- recursos linguisticos en `runtime/freeling/share/freeling/common/`;
- recursos linguisticos en `runtime/freeling/share/freeling/es/`.

Instalacion no interactiva para mantenedores:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling --yes
```

`patch_freeling_rpath.sh` configura `_pyfreeling.so` y las librerias nativas
para que resuelvan `runtime/freeling/lib/` mediante RPATH/RUNPATH. Despues de
ese paso, no hace falta exportar `LD_LIBRARY_PATH` manualmente en cada terminal.

## spaCy

El backend ingles necesita:

- `spacy`;
- `pyphen`;
- modelo `en_core_web_sm`.

Instalacion no interactiva para mantenedores:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy --yes
```

## Descarga de assets

Los scripts descargan los assets desde la Release publica de GitHub mediante
`curl` o `wget`. GitHub CLI no es necesario para el flujo normal.

Si el repositorio vuelve a ser privado, los mismos scripts pueden usar GitHub
CLI como fallback tras ejecutar `gh auth login` en la misma terminal Ubuntu/WSL.
