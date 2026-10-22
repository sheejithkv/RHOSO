# RHOSO SOP production release gate

!!! danger "CURRENT DECISION: NO-GO for production-authoritative L1 use"
    Repository CI verifies **documentation and mocked script behavior**, not live RHOSO compatibility, authenticating services, correct CLI privileges, or end-to-end tenant transactions. The four existing SOPs remain DRAFT.

## Release criteria (must all be complete)

- [ ] **Named owner and approver** for each production-approved SOP; support team and review date.
- [ ] Exact **RHOSO micro-release / OpenShift / EDPM / Ceph / enabled services**, documented in [compatibility](COMPATIBILITY.md).
- [ ] Commands reviewed against installed CLI/plugins/CRDs with actual namespace, pod and container discovery; uncertain commands labeled UNVERIFIED.
- [ ] L1 read-only steps and L2/L3 approved changes separated and reviewed.
- [ ] Production maintenance changes have authoritative Operator/GitOps/Helm ownership, impact, stop conditions and tested rollback.
- [ ] Incidents trace the original transaction with matching request ID/time; validation reproduces it.
- [ ] Daily health-check is tested against controlled healthy/degraded/unavailable fixtures **and** observed on a permitted RHOSO test environment.
- [ ] Critical incident SOPs cover Nova/Placement, compute registration, OVN/Neutron, Cinder/Ceph, RabbitMQ, Galera and RHOSO Operators; no fabricated runbook claims.
- [ ] Backup evidence includes supported, isolated restore exercise and RPO/RTO sign-off for actual backends.
- [ ] Required PR review, CI and branch protection are configured and independently verified.
- [ ] The live Pages URL is accessible from engineer networks; navigation/search/browser/print checks pass.
- [ ] L1/L2/L3 training and escalation simulation completed with documented feedback.

## Sign-off record

| Role | Name / approval ID | Date UTC | Status |
| --- | --- | --- | --- |
| RHOSO platform owner | Unassigned | — | NOT APPROVED |
| OpenShift/EDPM lead | Unassigned | — | NOT APPROVED |
| Networking/Storage leads | Unassigned | — | NOT APPROVED |
| Incident/on-call operations | Unassigned | — | NOT APPROVED |
| Disaster recovery owner | Unassigned | — | NOT APPROVED |

**A green MkDocs build or PR merge is never production certification.**
