# Troubleshooting Midolec V6

Este documento recoge errores frecuentes durante la instalacion y ejecucion de
la distribucion interna de Midolec V6.

Los comandos se ejecutan desde la raiz del paquete:

```bash
cd midolec-v6
```

## GitHub CLI no esta instalado

Sintoma:

```text
gh: command not found
```

Tambien puede aparecer como:

```text
GitHub CLI (gh) is required to download runtime assets from a private GitHub Release.
Install it and authenticate before running this script: gh auth login
```

Causa probable:

GitHub CLI no esta instalado en la maquina. Es necesario porque los assets
runtime estan publicados en una Release privada.

Solucion:

```bash
gh --version
```

Si el comando no existe, instalar GitHub CLI siguiendo las instrucciones
oficiales o las indicaciones del equipo.

En validaciones internas de desarrollo se puede usar la opcion `--from-dir` de
los scripts de FreeLing para copiar assets desde una carpeta local ya validada.
Esa opcion no sustituye al flujo normal para colaboradores, que debe usar la
Release privada.

## El usuario no tiene acceso a la Release privada

Sintomas habituales:

```text
HTTP 404
not found
permission denied
```

Causa probable:

La cuenta autenticada con GitHub CLI no tiene acceso al repositorio privado
`gigabd-uc3m/midolec-dist`, o no se ha ejecutado `gh auth login`.

Solucion:

```bash
gh auth login
gh auth status
```

Si `gh auth status` funciona pero la descarga sigue fallando, pedir acceso al
repositorio de distribucion.

## Falta patchelf

Sintoma:

```text
ERROR: patchelf is not installed.
```

Causa probable:

El sistema no tiene instalada la herramienta necesaria para escribir RPATH o
RUNPATH en `_pyfreeling.so` y en las librerias nativas.

Solucion en Ubuntu/WSL:

```bash
sudo apt update
sudo apt install -y patchelf
```

Despues, repetir:

```bash
bash runtime/provisioning/patch_freeling_rpath.sh .
```

## Missing FreeLing RPATH/RUNPATH configuration

Sintoma:

```text
Missing FreeLing RPATH/RUNPATH configuration
```

Causa probable:

Las librerias de FreeLing existen en `runtime/freeling/lib/`, pero
`_pyfreeling.so` todavia no sabe resolverlas automaticamente desde esa carpeta.

Solucion:

```bash
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh
```

No se debe resolver este error exportando `LD_LIBRARY_PATH` manualmente. La
estrategia actual de V6 es usar RPATH/RUNPATH.

## Falta una libreria nativa de FreeLing

Sintomas habituales:

```text
libfreeling.so: cannot open shared object file
libfoma.so: cannot open shared object file
libtreeler.so: cannot open shared object file
libdynet.so: cannot open shared object file
libcrfsuite.so: cannot open shared object file
```

Causa probable:

No se han descargado las librerias nativas compatibles con esta build de
Midolec V6, o se han borrado de `runtime/freeling/lib/`.

Solucion:

```bash
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh --libs-only
```

## Undefined symbol en _pyfreeling.so

Sintoma:

```text
undefined symbol: _ZN8freeling...
```

Causa probable:

`_pyfreeling.so` esta intentando cargar una version de `libfreeling.so`
incompatible. Esto puede ocurrir si se usan librerias del sistema o librerias
copiadas desde otra build.

Solucion:

```bash
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh --libs-only
```

Si el error persiste, eliminar `runtime/freeling/lib/` y repetir la instalacion
desde la Release oficial de `midolec-dist`.

## Faltan recursos linguisticos de FreeLing

Sintomas habituales:

```text
Missing FreeLing resource folders
cannot open tokenizer.dat
cannot open splitter.dat
```

Causa probable:

No estan instaladas las carpetas `common/` y `es/` en
`runtime/freeling/share/freeling/`.

Solucion:

```bash
bash runtime/provisioning/install_freeling_resources.sh
bash runtime/provisioning/check_freeling_runtime.sh --resources-only
```

## El backend ingles no encuentra spaCy o pyphen

Sintomas habituales:

```text
No module named spacy
No module named pyphen
Can't find model 'en_core_web_sm'
```

Causa probable:

No se han instalado las dependencias del backend ingles.

Solucion:

```bash
bash runtime/provisioning/install_spacy_en.sh
```

## El binario no encuentra spaCy aunque install_spacy_en.sh haya funcionado

Sintoma:

```text
Midolec V6 cannot start English analysis because the spaCy runtime is incomplete.
Missing Python dependencies:
  - Python package 'spacy'
  - Python package 'pyphen'
```

Causa probable:

El script `install_spacy_en.sh` instala dependencias en el Python del sistema y
copia el modelo ingles a `runtime/spacy/models/`. Sin embargo, el binario
PyInstaller ejecuta los modulos Python empaquetados en `_internal/`. Si la build
del binario no incluyo `spacy` y `pyphen`, el binario no podra importarlos aunque
esten instalados en el sistema.

Solucion para desarrolladores:

Generar una nueva build PyInstaller incluyendo `spacy`, `pyphen` y los imports
necesarios del backend ingles. Despues, repetir:

```bash
bash runtime/provisioning/install_spacy_en.sh
./midolec-v6 -L en input_text.txt
```

No se recomienda intentar arreglar este caso copiando manualmente paquetes de
`site-packages` dentro de `_internal/`, porque es fragil y dificil de reproducir.

Estado conocido:

En la validacion WSL del 2026-05-13, el backend ingles funciono correctamente
desde codigo fuente y paso su bateria completa, pero el binario de distribucion
quedo pendiente de nueva build con `spacy` y `pyphen` incluidos.

## No se genera el JSON de salida

Sintoma:

El comando termina con error o no aparece el fichero `.json` esperado.

Comprobaciones recomendadas:

```bash
./midolec-v6 -H
./midolec-v6 input_text.txt
```

Revisar:

- que el fichero de entrada existe;
- que se esta ejecutando desde `midolec-v6/`;
- que `midolecConfig.toml` y `config/` estan junto al binario;
- que `runtime/provisioning/check_freeling_runtime.sh` termina sin errores si
  se usa espanol/FreeLing.

## Informacion que conviene reportar

Cuando un colaborador reporte un fallo, pedir:

```text
Sistema operativo:
Comando ejecutado:
Salida completa del error:
Resultado de gh auth status:
Resultado de bash runtime/provisioning/check_freeling_runtime.sh:
Commit o version de midolec-dist:
```
