# SOP improvement proposals and implementation backlog

**Status:** These are suggestions, **not implemented controls**. Track each proposed item through an issue/PR, a technical owner, test evidence and an approval date. Reprioritize using incident frequency, risk and operational value.

| Priority | Suggestion | Acceptance criteria | State |
| --- | --- | --- | --- |
| P0 | Protect main branch | Required PR reviews, no force-push, required checks, restricted write permissions; verified in GitHub settings | PROPOSED |
| P0 | Version-specific RHOSO support matrix | Each state-changing SOP records RHOSO micro release, OpenShift, EDPM RHEL, enabled components and verified vendor source | PROPOSED |
| P0 | Source-of-truth mapping | Procedures link Operator CR, GitOps/Argo CD, Helm or other owning controller before any configuration write | PROPOSED |
| P0 | Disaster recovery drill evidence | Backup SOP links nonproduction restore exercise, object-store/DB/volume verification, RPO/RTO results and approval | PROPOSED |
| P1 | Syntax and secret scanning | CI checks scripts with bash -n and ShellCheck; scans changes for credentials; prevents publication of raw incident artifacts | PROPOSED |
| P1 | Markdown link and lint checks | CI verifies local document paths, references, headings and unsupported/obsolete RHOSP syntax markers | PROPOSED |
| P1 | Incident-to-SOP feedback | Every significant post-incident action links first proven failure, minimal fix, test outcome, and an SOP issue/PR | PROPOSED |
| P1 | Synthetic API/data-plane validation | Explicit safe tenant flow verifies identity, image, scheduling, networking and storage with controlled cleanup | PROPOSED |
| P1 | Machine-readable SOP inventory | Metadata for ID, owner, release, status, last tested and review due; CI flags unowned/expired APPROVED SOPs | PROPOSED |
| P2 | Operator run evidence packs | A single read-only, domain-specific collector per incident class produces timestamped, redacted evidence | PROPOSED |
| P2 | Capacity and SLO guardrails | Defined thresholds for compute, Placement, Cinder, RabbitMQ, Galera, OVN/Neutron and Ceph; alert routing | PROPOSED |
| P2 | Quarterly review cadence | Quarterly revisit of version support, commands, recovery prerequisites and links; archive deprecated SOPs | PROPOSED |

## How to submit an improvement

Open a GitHub issue or PR and supply:
- **Observed gap:** which exact operational transaction failed or what manual work is error-prone.
- **Environment:** RHOSO/OpenShift/EDPM version, feature flags, and relevant topology without secrets.
- **Evidence:** first proven failure with timestamp and request ID, or a reasoned improvement proposal.
- **Recommendation:** minimum technical/documentation change, source of truth and owner.
- **Safety:** blast radius, alternatives, rollback and validation of the original transaction.
- **Status:** PROPOSED -> IN REVIEW -> VERIFIED -> COMPLETED (or REJECTED).

Do not mark a proposal COMPLETED merely because a command was added; acceptance must be reviewed and verified.