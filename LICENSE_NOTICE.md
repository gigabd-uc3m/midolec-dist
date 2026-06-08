# License notice

This repository is currently intended for internal evaluation and packaged
testing of Midolec distribution packages.

Midolec V6 and V7-a1 may call FreeLing for Spanish text preprocessing and word
categorization. FreeLing is distributed under AGPL terms. Midolec uses FreeLing
as a detachable NLP backend and does not modify FreeLing itself.

The GigaBD development group is still pending a full review of the internal
binary packages for privacy and redistribution purposes.

Until that review is complete:

- Do not publish this repository as a public distribution channel.
- Do not redistribute FreeLing-based Midolec binaries outside the authorized
  internal collaborator group.
- Keep source-code, runtime assets, and executable packages traceable to the
  corresponding internal release.
- Treat `midolec-v7-a1/` as a partial alpha package until explicitly promoted.
