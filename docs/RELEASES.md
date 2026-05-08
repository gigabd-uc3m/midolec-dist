# Releases

Los binarios y recursos pesados deben publicarse como assets de GitHub Releases,
no como ficheros versionados en `main`.

## Convencion de versiones

Para V6, mientras siga siendo una version intermedia:

```text
v6.0.0-alpha.1
v6.0.0-alpha.2
v6.0.0-beta.1
```

Para versiones historicas cerradas, como V4.2:

```text
v4.2.0
```

## Assets recomendados

Cada Release deberia incluir:

- paquete ejecutable de Midolec;
- librerias FreeLing compatibles, si aplica;
- recursos FreeLing, si aplica;
- checksums `SHA256SUMS`;
- guia breve de ejecucion de esa version.

## Publicacion futura

Antes de hacer publica una Release con FreeLing debe revisarse la compatibilidad
con AGPL y decidir si se publicara tambien el codigo fuente correspondiente.
