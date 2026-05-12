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
