# Validacion Midolec V6

Este documento recoge el procedimiento minimo para validar que el paquete
interno de Midolec V6 funciona correctamente en un entorno Linux/WSL.

La finalidad de esta validacion no es certificar todas las funcionalidades del
analizador, sino comprobar que la distribucion interna arranca, carga su
configuracion, prepara sus dependencias runtime y genera una salida JSON
basica.

## Objetivo

Comprobar que:

- el binario `midolec-v6` arranca correctamente;
- la configuracion TOML se carga;
- las dependencias runtime de FreeLing se instalan correctamente;
- `_pyfreeling.so` resuelve las librerias nativas mediante RPATH/RUNPATH;
- el backend espanol genera un JSON de salida;
- el usuario no necesita exportar `LD_LIBRARY_PATH` manualmente.

## Entorno probado

Completar tras cada validacion:

```text
Fecha:
Maquina:
Sistema operativo:
Usuario que valida:
Commit de midolec-dist:
Release de runtime assets:
Paquete/binario probado:
```

## Preparacion del runtime

Ejecutar desde la raiz del paquete:

```bash
cd midolec-v6
gh auth login
bash runtime/provisioning/install_freeling_libs.sh
bash runtime/provisioning/install_freeling_resources.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh
```

## Prueba minima de ejecucion

Crear un fichero de prueba:

```bash
printf "El paciente debe acudir a las 14:30 h. al Centro de Salud." > prueba_v6.txt
```

Ejecutar Midolec:

```bash
./midolec-v6 prueba_v6.txt
```

Resultado esperado:

- el programa no muestra errores de librerias `.so`;
- no pide exportar `LD_LIBRARY_PATH`;
- genera un fichero `prueba_v6.json`;
- el JSON contiene informacion de analisis del texto.

## Prueba de configuracion

Modificar temporalmente una opcion de `midolecConfig.toml`, por ejemplo:

```toml
include_empty_attributes = true
```

Volver a ejecutar:

```bash
./midolec-v6 prueba_v6.txt
```

Resultado esperado:

- el programa sigue funcionando;
- el JSON refleja el cambio de configuracion.

Despues, restaurar el valor anterior.

## Criterio de validacion

La version se considera validada para prueba interna si:

- `check_freeling_runtime.sh` termina sin errores;
- `./midolec-v6 prueba_v6.txt` genera JSON correctamente;
- no aparece ningun error de tipo `libfreeling.so not found`, `undefined symbol`,
  `Missing FreeLing RPATH/RUNPATH configuration` o similar;
- no hace falta ejecutar manualmente `export LD_LIBRARY_PATH=...`.

## Incidencias encontradas

Registrar aqui cualquier problema:

```text
Fecha:
Maquina:
Comando:
Error:
Solucion aplicada:
Pendiente:
```

## Estado final

Completar tras la validacion:

```text
Validado: si/no
Validado por:
Fecha:
Observaciones:
```

## Validacion WSL local - 2026-05-13

Esta validacion se ha realizado en el entorno local WSL de desarrollo para
comprobar tanto el codigo fuente como el paquete de distribucion interna.

```text
Fecha: 2026-05-13
Maquina: LAPTOP-IJVIND2J
Sistema operativo: Ubuntu sobre WSL2
Kernel: 5.15.153.1-microsoft-standard-WSL2
Python: 3.10.12
Usuario que valida: Juan Romero (juaromer@pa.uc3m.es)
Commit de source repo al inicio de la validacion: b77a8a6
LD_LIBRARY_PATH: no definido
Runtime assets: instalados localmente desde runtime validado
```

### Codigo fuente V6

Resultado general: validado para ejecucion local WSL en espanol e ingles.

Comprobaciones realizadas:

- `bash v6/runtime/provisioning/check_freeling_runtime.sh`: correcto.
- `python3 v6/midolec.py -H`: correcto.
- Ejecucion espanola con FreeLing: genera JSON valido.
- Bateria `es-2026_juridica_avanzada`: 70/70 comprobaciones configuradas correctas.
- Bateria `es-2025_bateria_funcionalidades`: 120/120 comprobaciones configuradas correctas, 20 comprobaciones deshabilitadas, 0 errores.
- Provisioning ingles con `install_spacy_en.sh`: correcto tras ajustar la copia del modelo spaCy.
- Ejecucion inglesa con spaCy: genera JSON valido.
- Bateria `en-2025_bateria_funcionalidades`: 200/200 comprobaciones configuradas correctas.

Durante la validacion se han actualizado expectativas de testing cuando el
comportamiento actual se ha considerado correcto:

- `phone_numbers` y `abbreviations` en la bateria espanola antigua.
- `difficult_terms` en la bateria inglesa.

Tambien se ha corregido la logica de testing para extraer correctamente algunas
familias de sugerencias inglesas y el nuevo formato estructurado de telefonos.

### Paquete de distribucion `midolec-v6`

Resultado general: validado para espanol/FreeLing en WSL sin usar
`LD_LIBRARY_PATH`.

Comprobaciones realizadas desde el paquete de distribucion:

- `./midolec-v6 -H`: correcto.
- Instalacion de librerias FreeLing mediante `--from-dir`: correcta.
- Instalacion de recursos FreeLing mediante `--from-dir`: correcta.
- `bash runtime/provisioning/patch_freeling_rpath.sh .`: correcto.
- `bash runtime/provisioning/check_freeling_runtime.sh`: correcto.
- Ejecucion espanola con `env -u LD_LIBRARY_PATH ./midolec-v6 ...`: genera JSON valido.

Se ha comprobado especificamente que el binario espanol funciona sin exportar
`LD_LIBRARY_PATH`, porque en la solucióna actual `_pyfreeling.so` resuelve las 
librerias nativas de FreeLing mediante RPATH/RUNPATH hacia `runtime/freeling/lib/`.

### Incidencias detectadas

1. El entorno local no tenia `gh` instalado. Por tanto, los scripts de descarga
   desde GitHub Release privada no pudieron probarse directamente en este WSL.
   Para esta validacion se uso la opcion de desarrollo `--from-dir`, copiando
   assets desde un runtime local ya validado.

2. La primera version de `install_spacy_en.sh` copiaba el paquete Python
   `en_core_web_sm`, pero no siempre dejaba el directorio cargable con
   `config.cfg` en la raiz de `runtime/spacy/models/en_core_web_sm/`. Se ha
   corregido el script para copiar la carpeta real del modelo.

3. El primer binario de distribucion no pudo ejecutar ingles aunque el modelo
   spaCy estuviera instalado en `runtime/spacy/models/`. El motivo era que esa
   build PyInstaller no incluia los paquetes Python `spacy` y `pyphen` dentro
   de `_internal/`. Se genero una nueva build incorporando esas dependencias
   Python en el binario, manteniendo el modelo ingles como recurso runtime
   externo.

4. Durante la validacion de la nueva build se detecto un error `division by
   zero` al procesar entradas no naturales en ingles, por ejemplo un fichero
   TOML usado accidentalmente como texto de entrada. El fallo estaba en el
   calculo de ratios cuando una oracion no tenia palabras analizables. Se
   corrigio en el codigo fuente y se reconstruyo el binario.

### Estado final de esta validacion

```text
Codigo fuente V6 espanol: validado
Codigo fuente V6 ingles: validado
Binario distribucion espanol: validado
Binario distribucion ingles: validado con spacy/pyphen incluidos en _internal/
Modelo ingles spaCy: recurso runtime externo en runtime/spacy/models/
LD_LIBRARY_PATH manual: no necesario para espanol/FreeLing
```
