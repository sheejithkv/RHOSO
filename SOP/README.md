# RHOSO 18.x — Standard Operating Procedures

> [!WARNING]
> **DRAFT / engineering reference.** The procedures have not been validated against a live RHOSO installation. Confirm your RHOSO micro-release, actual topology, authorization, and change-control requirements before use.

**One source of truth:** every SOP is maintained as a Markdown file in this directory. The searchable, navigable website is generated from these files by MkDocs Material. **There are no separate HTML SOPs to edit.**

## SOP catalogue

| Area | Procedure | Worked example |
| :--- | :--- | :--- |
| Operations | [SOP-OPS-001 — Daily RHOSO health check](operations/daily-health-check.md) | [Example](operations/EXAMPLE.md) |
| Incidents | [SOP-INC-001 — VM stuck in BUILD / ERROR](incidents/vm-build-failure.md) | [Example](incidents/EXAMPLE.md) |
| Maintenance | [SOP-MNT-001 — Compute host maintenance](maintenance/compute-host-maintenance.md) | [Example](maintenance/EXAMPLE.md) |
| Recovery | [SOP-REC-001 — Backup readiness](recovery/backup-readiness.md) | [Example](recovery/EXAMPLE.md) |

## How to update an SOP

1. Open its Markdown file above and select **Edit** (or edit locally on a new Git branch).
2. Update the commands, execution context, expected results, validation, rollback, version and references. Keep the first proven failure boundary explicit in incident procedures.
3. If the walkthrough changes, edit its linked **EXAMPLE.md**. Clearly distinguish simulated data from observed production evidence.
4. Update [CHANGELOG.md](CHANGELOG.md), open a pull request, and verify the automated **MkDocs build** succeeds.
5. After technical review, merge to `main`. GitHub Actions automatically rebuilds and publishes the site to the `gh-pages` branch. A one-time GitHub Pages setting must select **Deploy from a branch → gh-pages / (root)** for the public site to become available.

To **add** an SOP, copy [TEMPLATE.md](TEMPLATE.md) to the appropriate category, give it a unique ID, link an example, add a link to this catalogue, and register it in the `nav` section of the root `mkdocs.yml`.

## Publishing and local preview

~~~bash
# Run from the repository root in an isolated Python environment.
python -m pip install -r requirements-docs.txt
mkdocs serve
# Open http://127.0.0.1:8000/

# Production site build; fails on documentation warnings.
mkdocs build --strict
~~~

The expected Pages address is **https://sheejithkv.github.io/RHOSO/** after Pages is configured and its deployment succeeds. The site is public: do not commit production credentials, customer data, private IP inventory or unredacted incident logs.

## Engineering standard

- **[SOP template](TEMPLATE.md)** — consistent purpose, prerequisites, risk, numbered steps, expected results, validation, rollback and revision history.
- **[Contributing and approval rules](CONTRIBUTING.md)** — scope, evidence and release review.
- **[Improvement backlog](IMPROVEMENTS.md)** — proposals and technical debt.
- **[Revision history](CHANGELOG.md)** — tracked SOP changes.
- [RHOSO administration command reference](https://github.com/sheejithkv/RHOSO/tree/main/docs) — separate command catalogue.

The website is a *presentation* of the Markdown SOPs, not a separate authorization or source of truth. A green documentation build **does not** prove a RHOSO command is safe or correct in your cluster.