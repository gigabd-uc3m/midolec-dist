# Reporting Unknown V7-a1 Errors

Use this guide when an error is not covered by
[04_TROUBLESHOOTING.md](04_TROUBLESHOOTING.md).

V7-a1 is a partial alpha package, so please include enough detail to reproduce
the problem.

## Where To Send The Report

Send the report to:

[gigabd@uc3m.es](mailto:gigabd@uc3m.es?subject=%5Bmidolec-dist%5D%5Binstall%5D)

Use this subject prefix:

```text
[midolec-dist] [install]
```

## Report Template

```text
Midolec V7-a1 unknown error report

1. Operating system:
   Example: Ubuntu 22.04, WSL Ubuntu, Linux server distribution/version.

2. How the package was obtained:
   Example: git clone, downloaded ZIP, copied from another machine.

3. V7-a1 package state:
   Say whether the binary `midolec-v7-a1` exists in the package folder.

4. Current folder:
   Paste the output of:
   pwd

5. Command executed:
   Paste the exact command that failed.

6. Full terminal output:
   Paste everything printed by the terminal after running the command.

7. Configuration:
   Paste the relevant `[general]` and `[output]` sections from `midolecConfig.toml`.

8. Output files:
   Say whether a `.json` file or `.md` report was created.

9. Input file:
   Say whether the error happens with an example file or with a private text.
   If the text is private, do not send confidential content.

10. Expected result:
    Briefly describe what you expected Midolec to do.

11. Actual result:
    Briefly describe what happened instead.
```

## Privacy Reminder

Do not send confidential or sensitive text unless you have permission to share
it. If the problem only happens with a private document, describe the document
type and command used, but remove personal data and confidential content.
