# V7-a1 Troubleshooting

V7-a1 is a partial alpha package. Some helper scripts and validation coverage
may differ from V6 until the package is rebuilt and stabilized.

## 1. Binary Is Missing

Typical symptom:

```text
./midolec-v7-a1: No such file or directory
```

Likely cause:

The V7-a1 package scaffold exists, but the binary has not been rebuilt and
copied into `midolec-v7-a1/` yet.

Fix:

Rebuild the V7-a1 binary from the canonical `midolec` source repository and
copy the executable workspace into this folder. Do not copy
`v7/run_midolec_v6.sh`.

## 2. Markdown Report Is Not Generated

Check `midolecConfig.toml`:

```toml
[output]
generate_markdown_report = true
```

Also confirm the command actually produces a JSON output. The Markdown report
is derived from the JSON result.

## 3. Unsupported Shell On Windows

Use WSL Ubuntu on Windows. Do not run this Linux package from local
MobaXterm/Cygwin/MSYS/Git Bash shells.

## 4. Runtime Or Backend Failure

Check the package-specific runtime notes under:

```text
runtime/
runtime/provisioning/
```

If the problem is not covered, use
[06_REPORTING_UNKNOWN_ERRORS.md](06_REPORTING_UNKNOWN_ERRORS.md).
