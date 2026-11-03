# SOP document control, contribution and approval

All production-facing SOPs use the **corporate nine-section format** in [TEMPLATE.md](TEMPLATE.md). The MkDocs website is generated from each Markdown SOP; there is no separately maintained Word or HTML version.

## Authoring procedure

1. Create a branch from `main`. Edit the appropriate SOP Markdown under `SOP/operations/`, `SOP/incidents/`, `SOP/maintenance/`, or `SOP/recovery/`.
2. Update its document header/reference, revision number, developer/owner, document-control metadata, review and approval **placeholders**, revision table, and nine sections. Never fabricate signatures, approval dates or effective dates.
3. Section 6 must provide ordered implementation steps, explicit context ([OCP], [OS], [EDPM], [POD]), level (L1/L2/L3), commands, expected results, interpretation/stop condition, validation, rollback and escalation. Preserve actual transaction evidence, not guesses.
4. Confirm RHOSO/OpenShift minor and micro-release, CLI availability and deployed CRD/operator ownership against authoritative documentation. Distinguish PROVEN HEALTHY, PROVEN BROKEN, INFERENCE, HYPOTHESIS and UNKNOWN.
5. Confirm approved reconciler/source of truth, impact, change approval, rollback and the original-transaction test **before any write action**. Do not recommend restarts, deletion, migration or restoration speculatively.
6. Keep each category's worked example consistent. Mark all imaginary incidents, outputs and results **SIMULATED**.
7. Update [CHANGELOG.md](CHANGELOG.md), the relevant catalogue links, and MkDocs navigation for newly added SOPs.
8. Open a pull request and require human technical review plus passing MkDocs and structure checks. The controlled version remains DRAFT until [release gate](RELEASE-GATE.md) is signed off.

## Publication restrictions

The GitHub Pages site is a **public website**. Use public-safe wording and placeholders. Do **not** paste a regulated institution's confidential legal notice, internal IPs, private keys, tenant details, incident logs or customer information into the public repository. A confidential formally issued version must be hosted in the organization's approved restricted document-management system.

The document's signature fields are intentionally blank. No Git merge or site build constitutes written authorization or proves live-cluster command safety.

## Verification from repository root

```bash
bash -n scripts/rhoso-healthcheck.sh
python -m unittest discover -s tests -p 'test_*.py' -v
python -m pip install -r requirements-docs.txt
mkdocs build --strict --clean
git diff --check
```

For visual review, run `mkdocs serve`; inspect the incident SOP at desktop and mobile widths and use Print → Save as PDF to verify A4 page layout. CI tests markup and presence of sections but does not certify print rendering, live RHOSO behavior, or actual approvals.
