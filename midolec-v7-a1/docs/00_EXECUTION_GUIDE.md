# V7-a1 Execution Guide

This guide explains how to run the Midolec V7-a1 partial alpha package after
the `midolec-v7-a1` binary has been rebuilt and copied into this folder.

Use V7-a1 only for previewing V7 behavior. Use `midolec-v6/` for stable
execution.

## Quick Execution Flow

1. Use Ubuntu, WSL Ubuntu, or an SSH session connected to a Linux server.
2. Open a terminal in the `midolec-v7-a1/` folder.
3. Confirm the binary starts.
4. Process a V7-a1 example text.
5. Open the generated JSON and, if enabled, the generated Markdown report.

## Commands

```bash
cd midolec-v7-a1
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

If Markdown report generation is enabled in `midolecConfig.toml`, the package
may create a `.md` report next to the JSON output.

## Output Files

For:

```text
../examples/v7-a1/sample_es.txt
```

the expected generated files are:

```text
../examples/v7-a1/sample_es.json
../examples/v7-a1/sample_es.md
```

Generated JSON and Markdown report files are ignored by Git.

## Alpha Warning

V7-a1 is a partial alpha package. Installer behavior, dependency checks,
runtime completeness, and validation coverage may be different from V6 until a
full V7 distribution is prepared.
