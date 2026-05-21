# Guia de ejecucion

Este repositorio contiene la configuracion, documentacion y scripts necesarios
para ejecutar paquetes binarios de Midolec.

## Ejecucion rapida

1. Ejecuta el paquete en Ubuntu, WSL Ubuntu o una sesion SSH a Linux.
2. Descarga el paquete binario desde la Release interna correspondiente.
3. Ejecuta el instalador guiado de dependencias runtime.
4. Ejecuta Midolec sobre un fichero de texto.

No uses el shell local de MobaXterm/Cygwin/MSYS/Git Bash para esta build. Si
estas en Windows, abre WSL Ubuntu.

## Instalacion guiada recomendada

El flujo recomendado para usuarios no tecnicos es ejecutar un unico script
interactivo. El script pregunta si se quiere instalar FreeLing, spaCy o ambos,
muestra una checklist de dependencias, solicita confirmacion y resume el
resultado final:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
```

Si solo se quiere diagnosticar el entorno sin instalar nada:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend all
```

La instalacion directa, pensada para mantenedores o scripts automatizados, esta
documentada en `docs/01_DEPENDENCIAS_RUNTIME.md`.

## Espanol con FreeLing

FreeLing necesita librerias nativas y recursos linguisticos. El instalador
guiado se encarga de instalar los paquetes Ubuntu/WSL necesarios, descargar los
assets y verificar el runtime.

El script `patch_freeling_rpath.sh` deja `_pyfreeling.so` preparado para
encontrar las librerias nativas en `runtime/freeling/lib/`. Despues de ese paso,
no hace falta exportar `LD_LIBRARY_PATH` manualmente en cada terminal.

Si el instalador guiado muestra algun error, ejecutar la checklist:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend freeling
```

## Ingles con spaCy

El backend ingles necesita `spacy`, `pyphen` y el modelo `en_core_web_sm`. El
instalador guiado prepara estas dependencias cuando se selecciona spaCy.

Si el instalador guiado muestra algun error, ejecutar la checklist:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend spacy
```

## Comando de ejecucion

La distribucion V6 se ejecuta desde la carpeta `midolec-v6/`. Primero entra en
esa carpeta:

```bash
cd ~/midolec-dist/midolec-v6
```

Comprueba que el binario arranca:

```bash
./midolec-v6 -H
```

Procesa un ejemplo en espanol. Midolec creara automaticamente el fichero
`examples/es/legal_cross_references.json`:

```bash
./midolec-v6 examples/es/legal_cross_references.txt
```

Abre el JSON generado desde terminal:

```bash
nano examples/es/legal_cross_references.json
```

Si prefieres `vim`:

```bash
vim examples/es/legal_cross_references.json
```

Procesa un ejemplo en ingles. La opcion `-L en` indica que se use el backend
ingles:

```bash
./midolec-v6 -L en examples/en/plain_language_terms.txt
```

Abre el JSON generado desde terminal:

```bash
nano examples/en/plain_language_terms.json
```

Tambien se puede procesar un fichero propio:

```bash
./midolec-v6 texto.txt salida.json
```

Si no indicas `salida.json`, Midolec crea un JSON junto al fichero de entrada.
Tambien puedes abrir la carpeta `midolec-v6/examples/` con el explorador de
archivos y hacer doble clic sobre el resultado `.json`.
