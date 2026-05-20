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

## Espanol con FreeLing

FreeLing necesita librerias nativas y recursos linguisticos. El instalador
guiado se encarga de instalar los paquetes Ubuntu/WSL necesarios, descargar los
assets y verificar el runtime.

El script `patch_freeling_rpath.sh` deja `_pyfreeling.so` preparado para
encontrar las librerias nativas en `runtime/freeling/lib/`. Despues de ese paso,
no hace falta exportar `LD_LIBRARY_PATH` manualmente en cada terminal.

Instalacion no interactiva para mantenedores:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling --yes
```

## Ingles con spaCy

El backend ingles necesita `spacy`, `pyphen` y el modelo `en_core_web_sm`. El
instalador guiado prepara estas dependencias cuando se selecciona spaCy.

Instalacion no interactiva para mantenedores:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy --yes
```

## Comando de ejecucion

La distribucion V6 se ejecuta desde la carpeta `midolec-v6/`:

```bash
./midolec-v6 examples/es/legal_cross_references.txt examples/es/legal_cross_references.json
./midolec-v6 -L en examples/en/plain_language_terms.txt examples/en/plain_language_terms.json
```

Tambien se puede procesar un fichero propio:

```bash
./midolec-v6 texto.txt salida.json
```

Los JSON generados dentro de `examples/` estan ignorados por Git.
