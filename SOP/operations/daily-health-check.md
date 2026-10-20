# SOP-OPS-001: Daily RHOSO operational health check

| Field | Value |
| --- | --- |
| Status / version | DRAFT / 0.1.0 |
| Scope | RHOSO 18.x control plane, OpenShift, EDPM, enabled OpenStack services |
| Execution | [OCP] admin workstation; [OS] OpenStackClient via script |
| Owner / approver | To be assigned |
| Last site validation | Not performed |

## Transaction and acceptance

Purpose: determine whether each **implemented** read-only check succeeds; identify failed or unavailable checks and dispatch targeted investigation. This is **not** a synthetic tenant transaction test and cannot prove end-to-end health by itself.

## Prerequisites and discovery

- Authenticated oc session, jq, permissions to list relevant CRs/pods and exec into the intended OpenStackClient; service-specific components may not be deployed.
- Select the appropriate RHOSO namespace and cloud when multiple exist. Do not guess names.
- Report output is local and can expose topology; store under restricted access, never commit it.

~~~bash
# [OCP][RO] Validate CLI identity and control-plane discovery.
oc whoami
oc get openstackcontrolplanes -A
oc get openstackdataplanenodesets -A
oc get openstackdataplanedeployments -A

# [OCP][RO] Discover an authenticated client pod and its namespace.
oc get pods -A -o wide | grep -i openstackclient

# [OCP][RO] Validate health-check script syntax; no cluster changes.
bash -n scripts/rhoso-healthcheck.sh

# [OCP][RO] Execute; replace with the namespace discovered above.
RHOSO_NAMESPACE="<discovered-namespace>" bash scripts/rhoso-healthcheck.sh
~~~

## Interpret and triage

- **PASS**: implemented check passed at collection time; confirm real user/API transaction separately when incident-driven.
- **WARN**: degraded condition or warning; correlate timestamps and owner.
- **FAIL**: independently confirmed check failure; capture first proven failing boundary and incident request ID.
- **UNAVAILABLE**: check could not be completed (RBAC, absent optional component, unavailable CLI/context). Do **not** conflate with either healthy or failed.
- Exit 0 = checks pass, 1 = warnings/unavailable, 2 = failures/prerequisite failure, per current script implementation.

Capture the script's generated report path, timestamp, precise scope, failed commands, output redaction status, and ticket reference. Correlate with **original user-visible transaction**, not only a pod list.

## Handover and change safety

No automatic restarts, pod deletion, failover, CR edits, or recovery. Route abnormal results to the service owner. Follow the relevant incident SOP for the first proven failure. Record gaps as issues and link [IMPROVEMENTS.md](../IMPROVEMENTS.md).

**Completion:** archived redacted summary, assigned follow-ups, and confirmation whether an end-to-end test has or has not been performed.