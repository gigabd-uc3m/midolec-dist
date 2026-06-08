# Version Matrix

| Version Folder | Status | Binary Name | Main Outputs | Recommended Use |
| --- | --- | --- | --- | --- |
| `midolec-v6/` | Stable internal package | `midolec-v6` | JSON | Regular execution, validation, demos, and collaborator testing. |
| `midolec-v7-a1/` | Partial alpha build | `midolec-v7-a1` | JSON and optional Markdown | Preview of V7 output behavior and Markdown reports. |

## V6

V6 is the currently recommended package for stable use. It includes a Linux
binary, editable TOML configuration, V6 documentation, runtime provisioning
helpers, examples, and validation guidance.

Use V6 when you need the most reliable distribution package.

## V7-a1

V7-a1 is a partial alpha build. It is intended for internal testing of V7
features and should be introduced to users as a preview package.

The main V7-a1 goals are:

- test Markdown report generation;
- test the V7 Findings-oriented JSON output;
- validate configuration changes before a stable V7 distribution exists;
- collect feedback without replacing V6.

V7-a1 may not provide the same installer, doctor checks, runtime completeness,
or validation guarantees as V6 until the package is rebuilt and explicitly
validated.
