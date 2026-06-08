# Reporting Unknown Errors

Use this guide when an error is not covered by the package-specific
troubleshooting documentation.

Please do not summarize the error from memory. Copy the exact command and the
full terminal output whenever possible.

## Package-Specific Guides

- V6 troubleshooting: [../midolec-v6/docs/03_TROUBLESHOOTING.md](../midolec-v6/docs/03_TROUBLESHOOTING.md)
- V6 unknown-error template: [../midolec-v6/docs/06_REPORTING_UNKNOWN_ERRORS.md](../midolec-v6/docs/06_REPORTING_UNKNOWN_ERRORS.md)
- V7-a1 troubleshooting: [../midolec-v7-a1/docs/04_TROUBLESHOOTING.md](../midolec-v7-a1/docs/04_TROUBLESHOOTING.md)
- V7-a1 unknown-error template: [../midolec-v7-a1/docs/06_REPORTING_UNKNOWN_ERRORS.md](../midolec-v7-a1/docs/06_REPORTING_UNKNOWN_ERRORS.md)

## Where To Send The Report

Send the report to:

[gigabd@uc3m.es](mailto:gigabd@uc3m.es?subject=%5Bmidolec-dist%5D%5Binstall%5D)

Use this subject prefix:

```text
[midolec-dist] [install]
```

## Minimum Information

Include:

- operating system and environment, for example Ubuntu, WSL Ubuntu, or Linux server;
- package version, for example `midolec-v6` or `midolec-v7-a1`;
- how the package was obtained, for example Git clone, ZIP download, or release asset;
- current folder, command executed, and full terminal output;
- dependency-check output when the package provides a checker;
- whether the problem happens with an example text or with a private document.

## Privacy Reminder

Do not send confidential or sensitive text unless you have permission to share
it. If the problem only happens with a private document, describe the document
type and command used, but remove personal data and confidential content.
