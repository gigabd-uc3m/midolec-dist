# Guia de ejecucion

Este repositorio contiene la configuracion, documentacion y scripts necesarios
para ejecutar paquetes binarios de Midolec.

## Ejecucion rapida

1. Ejecuta el paquete en Ubuntu, WSL Ubuntu o una sesion SSH a Linux.
2. Descarga el paquete binario desde la Release interna correspondiente.
3. Instala las dependencias runtime necesarias.
4. Ejecuta Midolec sobre un fichero de texto.

No uses el shell local de MobaXterm/Cygwin/MSYS/Git Bash para esta build. Si
estas en Windows, abre WSL Ubuntu.

## Espanol con FreeLing

FreeLing necesita librerias nativas y recursos linguisticos. Se instalan con:

```bash
cd midolec-v6
sudo apt update
sudo apt install -y curl patchelf libboost-regex1.74.0 libboost-program-options1.74.0
bash runtime/provisioning/install_configure_freeling.sh
```

El script `patch_freeling_rpath.sh` deja `_pyfreeling.so` preparado para
encontrar las librerias nativas en `runtime/freeling/lib/`. Despues de ese paso,
no hace falta exportar `LD_LIBRARY_PATH` manualmente en cada terminal.

## Ingles con spaCy

El backend ingles necesita `spacy`, `pyphen` y el modelo `en_core_web_sm`:

```bash
cd midolec-v6
bash runtime/provisioning/install_spacy_en.sh
```

## Comando de ejecucion

El comando exacto dependera del paquete binario generado para cada Release. La
Release debe documentar si se ejecuta como:

```bash
./midolec-v6 texto.txt
```

o mediante otro nombre de ejecutable indicado en la Release.
