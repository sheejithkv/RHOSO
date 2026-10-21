# Authoring and approving RHOSO SOPs

1. Start with [TEMPLATE.md](TEMPLATE.md). Create a uniquely numbered document under `operations/`, `incidents/`, `maintenance/` or `recovery/`.
2. Make the **visible procedure** work like a production document: title/metadata, purpose, scope, prerequisites, safety gate, decision flow, step matrix, one code block per step, expected result, validation, rollback, references and dated revisions.
3. Use `[OCP]`, `[OS]`, `[EDPM]`, `[POD]`, or `[CEPH]`. **Discover real pods/containers first** and document authentication rather than credentials. Never assume optional services or TripleO deployment models.
4. Evidence is transactional: actual failing request/time, first proven failure, causal chain only as far as logs support, distinctions among proven healthy/broken, inference, hypothesis and unknown. Do not infer root cause from error labels alone.
5. Identify Operator CR, GitOps, Helm or other authoritative configuration ownership before any write. Require owner, change ticket, prerequisites, impact, risk, rollback and **original-transaction** validation. No restarts or cleanup by default.
6. Keep worked examples under each category's `EXAMPLE.md`. Use named **SIMULATED** samples with placeholders: `<VM_UUID>`, `<discovered-namespace>`. Never portray fabricated log lines as real incidents.
7. Review exact command flags against the installed CLI and [Red Hat documentation](../docs/official-sources.md). If not verified, label it `UNVERIFIED` and omit risky execution.
8. Keep procedure versions and target RHOSO micro-release/current compatibility matrix. A procedure cannot be APPROVED without recorded site verification and reviewer/approver identity.
9. Update [CHANGELOG.md](CHANGELOG.md), cross-links and example when changing a procedure. Use a pull request; repository branch protections and reviewers must be configured separately.

## Release checklist

- [ ] Purpose, scope, prerequisite privileges and exact release/optional topology
- [ ] Dynamic resource discovery; no invented names or CIDRs
- [ ] Step matrix includes command **and** expected result **and** interpretation
- [ ] Evidence crosses only the proven fault-domain boundary
- [ ] Change steps gated and owned; rollback/stop preconditions documented
- [ ] Validation recreates the original user-facing transaction
- [ ] One worked illustrative example exists in that category
- [ ] Red Hat links and status/revision/owner fields present
- [ ] No secrets, private keys, unredacted logs or tenant data
- [ ] Static checks pass; site validation evidence separately reviewed

**Change process:** PROPOSED → DRAFT → REVIEWED → APPROVED or DEPRECATED. GitHub UI approval does not imply site-tested infrastructure command safety.