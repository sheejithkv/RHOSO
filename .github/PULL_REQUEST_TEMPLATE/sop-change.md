## SOP scope

- SOP ID / file:
- Type: new / revision / deprecation
- RHOSO + OpenShift + EDPM release:
- Operational transaction addressed:
- Supporting Red Hat documentation (release-specific):

## Evidence and controller ownership

- [ ] PROVEN HEALTHY and PROVEN BROKEN are distinguished from hypotheses/unknowns
- [ ] First proven failure boundary and incident-time/request-ID evidence identified
- [ ] Operator / GitOps / Helm / other source-of-truth verified
- [ ] All variable names, namespaces, pods, and optional components are discovered or identified as prerequisites

## Production safety

- [ ] Read-only / change / destructive commands differentiated
- [ ] Change ticket, blast radius, stop conditions, and risks recorded where applicable
- [ ] Minimum safe change, rollback preconditions, and rollback steps reviewed
- [ ] No secrets, credentials, customer data, or raw incident evidence included

## Validation and release

- [ ] Original failing transaction is re-tested or the absence of target validation is explicitly documented
- [ ] Syntax and static tests performed as applicable
- [ ] Status (DRAFT/REVIEWED/APPROVED/DEPRECATED), owner, reviewer, version and review date updated
- [ ] SOP/CHANGELOG.md updated
- Test output / ticket reference:
- Approver:
