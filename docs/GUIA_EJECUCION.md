# Guia de ejecucion

Este repositorio contiene la configuracion, documentacion y scripts necesarios
para ejecutar paquetes binarios de Midolec.

## Ejecucion rapida

1. Descarga el paquete binario desde la Release interna correspondiente.
2. Instala las dependencias runtime necesarias.
3. Ajusta `LD_LIBRARY_PATH` si vas a ejecutar el backend espanol con FreeLing.
4. Ejecuta Midolec sobre un fichero de texto.

## Espanol con FreeLing

FreeLing necesita librerias nativas y recursos linguisticos. Se instalan con:

```bash
gh auth login
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/install_freeling_resources.sh
export LD_LIBRARY_PATH="$PWD/runtime/freeling/lib:${LD_LIBRARY_PATH:-}"
```

La variable `LD_LIBRARY_PATH` debe estar definida en cada terminal nueva antes
de ejecutar Midolec con FreeLing.

## Ingles con spaCy

El backend ingles necesita `spacy`, `pyphen` y el modelo `en_core_web_sm`:

```bash
bash runtime/provisioning/install_spacy_en.sh
```

## Comando de ejecucion

El comando exacto dependera del paquete binario generado para cada Release. La
Release debe documentar si se ejecuta como:

```bash
./midolec texto.txt
```

o mediante otro nombre de ejecutable.
