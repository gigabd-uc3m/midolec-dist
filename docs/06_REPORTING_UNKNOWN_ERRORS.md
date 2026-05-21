# Reporting Unknown Errors

Use this guide when an error is not covered by `03_TROUBLESHOOTING.md`.

Please do not summarize the error from memory. Copy the exact command and the
full terminal output whenever possible.

## Where To Send The Report

Send the report to:

[gigabd@uc3m.es](mailto:gigabd@uc3m.es?subject=%5Bmidolec-dist%5D%5Binstall%5D)

Use this subject prefix:

```text
[midolec-dist] [install]
```

## Before Reporting

From the `midolec-v6/` folder, run:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

If the issue happens while processing a text, also run:

```bash
./midolec-v6 -H
```

## Report Template

Copy and fill in this template:

```text
Midolec unknown error report

1. Operating system:
   Example: Ubuntu 22.04, WSL Ubuntu, Linux server distribution/version.

2. How the package was obtained:
   Example: git clone, downloaded ZIP, copied from another machine.

3. Midolec version or commit:
   If known, paste the Git commit, release tag, or download date.

4. Current folder:
   Paste the output of:
   pwd

5. Command executed:
   Paste the exact command that failed.

6. Full terminal output:
   Paste everything printed by the terminal after running the command.

7. Dependency checklist:
   Paste the full output of:
   bash runtime/provisioning/doctor.sh --backend all

8. Binary help check:
   Paste the output of:
   ./midolec-v6 -H

9. Input file:
   Say whether the error happens with an example file or with a private text.
   If the text is private, do not send confidential content.

10. Expected result:
    Briefly describe what you expected Midolec to do.

11. Actual result:
    Briefly describe what happened instead.

12. Extra context:
    Include screenshots, logs, or steps already tried if they help reproduce the issue.
```

## Privacy Reminder

Do not send confidential or sensitive text unless you have permission to share
it. If the problem only happens with a private document, describe the document
type and command used, but remove personal data and confidential content.
