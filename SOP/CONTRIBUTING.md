# SOP contribution and approval

**Update one Markdown SOP, not three viewers.** MkDocs renders Markdown automatically; do not hand-edit generated HTML.

## Engineer workflow

1. Create a branch from `main`. Edit a Markdown SOP in `SOP/operations/`, `SOP/incidents/`, `SOP/maintenance/` or `SOP/recovery/`.
2. For a new SOP, copy [TEMPLATE.md](TEMPLATE.md), assign a unique ID, link it in [README.md](README.md) and add one navigation entry in `mkdocs.yml`.
3. Capture the **actual transaction** and timestamp, and distinguish PROVEN HEALTHY, PROVEN BROKEN, INFERENCE, HYPOTHESIS and UNKNOWN. Show the first proven failure, not a guessed root cause.
4. Confirm the exact RHOSO/OpenShift release, API/CLI syntax, real resource discovery and optional-service prerequisites. Link current Red Hat documentation.
5. Before a change: identify Operator/GitOps/Helm ownership, approved authority, blast radius, stop conditions, minimum fix, rollback and validation that reproduces the original transaction. Do not recommend random restarts/deletions.
6. Update the category's `EXAMPLE.md` (or link a distinct new example) where needed; label fictional output **SIMULATED**.
7. Increment the SOP version, update its revision table and [CHANGELOG.md](CHANGELOG.md).
8. Open a pull request. Require technical review; verify **MkDocs build** and relevant command syntax. Only mark an SOP APPROVED after target-environment validation and named owner/approver evidence.

### Local checks

~~~bash
bash -n scripts/rhoso-healthcheck.sh
python -m pip install -r requirements-docs.txt
mkdocs build --strict
git diff --check
~~~

The built website is output to `site/` (ignored by Git), and GitHub Actions publishes it after merge. GitHub branch protections and required reviewers must be configured separately; this file does not enforce them.

**Never commit** kubeconfig, passwords, tokens, private keys, tenant data or unredacted production logs. A PR merge is documentation release, not production change approval.
