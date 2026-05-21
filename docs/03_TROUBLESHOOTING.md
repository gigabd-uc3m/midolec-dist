# Troubleshooting Midolec V6

Este documento recoge errores frecuentes durante la instalacion y ejecucion de
la distribucion interna de Midolec V6.

Los comandos se ejecutan desde la raiz del paquete:

```bash
cd midolec-v6
```

Antes de diagnosticar un caso concreto, ejecuta la checklist general:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

Si quieres que el propio paquete intente instalar lo que falta, ejecuta:

```bash
bash runtime/provisioning/install_midolec_runtime.sh
```

## 1) Entorno soportado

La build actual es un paquete Linux. Usar:

- Ubuntu o una distribucion Linux compatible.
- WSL Ubuntu en Windows.
- MobaXterm solo como cliente SSH hacia un servidor Linux.

No usar el shell local de MobaXterm/Cygwin/MSYS/Git Bash para instalar o
ejecutar esta build. Aunque parezcan terminales Unix, no son el entorno Ubuntu
esperado por el binario Linux ni por las librerias `.so` de FreeLing.

Comprobacion rapida:

```bash
uname -s
```

Resultado esperado:

```text
Linux
```

## 2) La descarga publica de assets falla

Sintoma:

```text
curl: ...
wget: ...
Direct public download failed; trying GitHub CLI fallback...
```

Causa probable:

No hay conexion con GitHub, la Release o el asset no existe, o no estan
instalados `curl`/`wget` en el entorno Ubuntu/WSL.

Solucion:

```bash
sudo apt update
sudo apt install -y curl
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

Si el repositorio de distribucion volviera a ser privado, entonces si haria
falta instalar GitHub CLI dentro de Ubuntu/WSL y ejecutar `gh auth login`.

## 3) Se esta usando MobaXterm local en Windows

Sintomas habituales:

```text
gh: command not found
cygstart: command not found
```

Causa probable:

El paquete se esta ejecutando desde el shell local de MobaXterm, por ejemplo
desde una ruta `/mnt/c/...`. Ese entorno usa una capa tipo Cygwin y no equivale
a Ubuntu/WSL.

Solucion:

Instalar WSL Ubuntu y ejecutar la instalacion desde una terminal Ubuntu, o usar
MobaXterm para conectarse por SSH a una maquina Linux real.

## 4) El repositorio vuelve a ser privado o no hay acceso a la Release

Sintomas habituales:

```text
HTTP 404
not found
permission denied
```

Causa probable:

La Release ya no es publica o la cuenta autenticada con GitHub CLI no tiene
acceso al repositorio `gigabd-uc3m/midolec-dist`.

Solucion:

```bash
gh auth login
gh auth status
```

Si `gh auth status` funciona pero la descarga sigue fallando, pedir acceso al
repositorio de distribucion. Este caso no deberia afectar al flujo normal
mientras `midolec-dist` sea publico.

## 5) Faltan paquetes Ubuntu/WSL de sistema

Sintoma visto en `freeling/check_runtime.sh`:

```text
libboost_program_options.so.1.74.0 => not found
```

Causa probable:

Los assets de FreeLing estan correctamente descargados, pero el sistema no
tiene una libreria compartida de Boost requerida por esa build.

Solucion en Ubuntu/WSL:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend freeling
```

## 6) Falta patchelf

Sintoma:

```text
ERROR: patchelf is not installed.
```

Causa probable:

El sistema no tiene instalada la herramienta necesaria para escribir
RPATH/RUNPATH en `_pyfreeling.so` y en las librerias nativas.

Solucion en Ubuntu/WSL:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

## 7) Missing FreeLing RPATH/RUNPATH configuration

Sintoma:

```text
Missing FreeLing RPATH/RUNPATH configuration
```

Causa probable:

Las librerias de FreeLing existen en `runtime/freeling/lib/`, pero
`_pyfreeling.so` todavia no sabe resolverlas automaticamente desde esa carpeta.

Solucion:

```bash
bash runtime/provisioning/freeling/patch_freeling_rpath.sh .
bash runtime/provisioning/freeling/check_runtime.sh
```

No se debe resolver este error exportando `LD_LIBRARY_PATH` manualmente. La
estrategia actual de V6 es usar RPATH/RUNPATH.

## 8) Falta una libreria nativa de FreeLing

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

Solucion recomendada:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

Solucion avanzada:

```bash
bash runtime/provisioning/freeling/install_libs.sh
bash runtime/provisioning/freeling/patch_freeling_rpath.sh .
bash runtime/provisioning/freeling/check_runtime.sh --libs-only
```

## 9) Undefined symbol en _pyfreeling.so

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
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend freeling
```

Si el error persiste, eliminar `runtime/freeling/lib/` y repetir la instalacion
desde la Release oficial de `midolec-dist`.

## 10) Faltan recursos linguisticos de FreeLing

Sintomas habituales:

```text
Missing FreeLing resource folders
cannot open tokenizer.dat
cannot open splitter.dat
```

Causa probable:

No estan instaladas las carpetas `common/` y `es/` en
`runtime/freeling/share/freeling/`.

Solucion recomendada:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

Solucion avanzada:

```bash
bash runtime/provisioning/freeling/install_resources.sh
bash runtime/provisioning/freeling/check_runtime.sh --resources-only
```

## 11) El backend ingles no encuentra spaCy o pyphen

Sintomas habituales:

```text
No module named spacy
No module named pyphen
Can't find model 'en_core_web_sm'
```

Causa probable:

No se han instalado las dependencias o el modelo del backend ingles.

Solucion:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy
bash runtime/provisioning/doctor.sh --backend spacy
```

## 12) PyInstaller no encuentra encodings

Sintoma:

```text
ModuleNotFoundError: No module named 'encodings'
Failed to start embedded python interpreter
```

Causa probable:

Falta `midolec-v6/_internal/base_library.zip` o la carpeta `_internal/` esta
incompleta. Esto suele pasar si la distribucion se ha copiado parcialmente.

Solucion:

Actualizar o volver a descargar `midolec-dist` completo. No intentar arreglarlo
instalando paquetes Python del sistema, porque el binario usa su runtime
PyInstaller empaquetado en `_internal/`.

## 13) No se genera el JSON de salida

Comprobaciones recomendadas:

```bash
./midolec-v6 -H
./midolec-v6 input_text.txt output.json
```

Revisar:

- que el fichero de entrada existe;
- que se esta ejecutando desde `midolec-v6/`;
- que `midolecConfig.toml` y `config/` estan junto al binario;
- que `bash runtime/provisioning/doctor.sh --backend all` muestra `OK` para los
  backends que se van a usar.

## Informacion que conviene reportar

Cuando un colaborador reporte un fallo, pedir:

```text
Sistema operativo:
Comando ejecutado:
Salida completa del error:
Resultado de uname -s:
Resultado de bash runtime/provisioning/doctor.sh --backend all:
Resultado de gh auth status, solo si se esta usando un repositorio privado:
Commit o version de midolec-dist:
```
