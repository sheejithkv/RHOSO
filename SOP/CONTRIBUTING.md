# Contributing, review and release workflow

1. **Request:** open an issue/change request with the user-visible failure or operational objective, release, affected topology, current/incident timestamps, and redacted evidence. Cross-link the [improvement backlog](IMPROVEMENTS.md).
2. **Draft:** copy [TEMPLATE.md](TEMPLATE.md) into the correct category: operations, incidents, maintenance, or recovery. Use stable SOP IDs and clear ownership. Start at **DRAFT** with no claim of live validation.
3. **Source audit:** cite current Red Hat RHOSO 18.x documentation, distinguish legacy RHOSP/TripleO syntax, document command execution context and options not yet verified, and confirm optional component availability.
4. **Safety review:** separate read-only probes, approved writes and destructive actions. Identify the first proven failure, controller ownership, exact minimal change, prerequisites, impact, stop condition and rollback.
5. **Validation:** collect syntax/static-check results and evidence from an authorized environment. Reproduce the original transaction before and after the change; a green Kubernetes status is insufficient.
6. **Pull request:** require at least one RHOSO/EDPM service reviewer and an operations approver for state-changing changes. The repository owner must configure branch protections and CODEOWNERS before calling this an enforced policy.
7. **Release:** update version, status, review date, scope and [CHANGELOG.md](CHANGELOG.md). Retain prior versions in git history; mark superseded SOPs DEPRECATED with a replacement link.

## Versioning

- **Major**: changes operation semantics, risk, or rollback process.
- **Minor**: expands scope or adds reviewed remediation steps.
- **Patch**: clarifications, new read-only evidence probes, link corrections.

**Never commit** cloud credentials, tokens, kubeconfigs, SSH private keys, unredacted diagnostics, tenant IPs, customer data, or log extracts with secrets. Reference secure ticketing/evidence storage instead. Redact samples before PR submission.

## Minimum review checklist

- [ ] Exact triggering transaction and first proven failure included
- [ ] Release, prerequisites and command contexts specified
- [ ] Read-only evidence separates incident-time/current-time facts
- [ ] Operator/GitOps/Helm ownership confirmed before writes
- [ ] No obsolete TripleO instructions or guessed names/CIDRs
- [ ] Changes use change control; blast radius, risk and rollback documented
- [ ] Validation reproduces the original transaction
- [ ] Version, state, reviewer and dated evidence updated
- [ ] No secrets, sensitive diagnostic artifacts or private tenant details
