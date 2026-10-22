# Worked example · Nova scheduler transaction investigation

> [!WARNING]
> **SIMULATED TRAINING EXAMPLE.** All evidence below is invented to illustrate documentation technique. Do not copy identifiers, assume a diagnosis or execute change steps without site approval.

| Field | Value |
| :--- | :--- |
| **Applicable SOP** | [SOP-INC-001](./vm-build-failure.md) |
| **Scenario** | Nova scheduler transaction investigation |
| **Status** | EXAMPLE ONLY / not approved |
| **Evidence type** | SIMULATED, not from a live cluster |
| **Contexts** | [OCP] workstation; [OS] authenticated OpenStackClient where specified |
| **Version** | RHOSO 18.x concept; exact micro-release unverified |

## 1. Purpose

Show an engineer how to apply the related SOP, interpret expected results, decide when to stop, and document the actual success criteria.

## 2. Scope

Training only. No real cluster objects, pod names, credentials, IP addresses or tenant identifiers.

## 3. Preconditions

Discover deployment, authenticate by approved method, verify installed OpenStackClient, and record incident or change ticket before action.

## 4. Impact and risks

> [!CAUTION]
> Do not translate fictional observations into production root-cause assertions. Mutating steps require formal change approval, ownership and documented rollback.

## 5. Decision path

```mermaid
flowchart TD
  A["Locate precise scope + request"] --> B["Read-only evidence"]
  B --> C{"First proven boundary?"}
  C -- "No" --> D["UNKNOWN: collect evidence / escalate"]
  C -- "Yes" --> E["Document impact and owner"]
  E --> F["Only approved action if needed"]
  F --> G["Reproduce original transaction"]
```

## 6. Detailed procedure — example walkthrough

| Step | What the engineer does | Simulated evidence / expected output | Interpretation / next action |
| :--- | :--- | :--- | :--- |
| 1 | Tenant reports VM request `<VM_UUID>` accepted but instance stays BUILD; capture timestamp and user request ID from secure ticket. | Document actual command output in secure incident ticket | Follow linked SOP; stop if ambiguous |
| 2 | Inside authenticated OpenStackClient, `openstack server show "$VM_UUID" -f yaml` establishes instance status; `openstack server event list "$VM_UUID"` inspects action history. | Document actual command output in secure incident ticket | Follow linked SOP; stop if ambiguous |
| 3 | **SIMULATED evidence:** `server status=BUILD`; one Nova scheduler log references a placement request with no eligible destination. This is an invented training scenario, **not** proof of the cause in a real cluster. | **SIMULATED** sample only | Do not extrapolate without live proof |
| 4 | Use Placement inventory, traits, quotas, AZ/aggregate and cell-mapping evidence to distinguish a proven scheduling rejection from hypotheses such as insufficient CPU or missing host registration. | Document actual command output in secure incident ticket | Follow linked SOP; stop if ambiguous |
| 5 | Do not restart scheduler or resize flavors. After separately approved evidence-driven correction, reproduce instance creation and verify guest status, actual host placement, ports, storage and console. | Document actual command output in secure incident ticket | Follow linked SOP; stop if ambiguous |

## 7. Validation

Do not restart scheduler or resize flavors. After separately approved evidence-driven correction, reproduce instance creation and verify guest status, actual host placement, ports, storage and console.

**Acceptance evidence:** record exact command/transaction, timestamp, expected vs actual user-visible result, fault-domain boundary and secure redacted ticket link.

## 8. Rollback / recovery

This example performs no live modifications. No automatic rollback is run. Approved changes must specify independent prerequisites and rollback before execution.

## 9. Troubleshooting and escalation

Classify observations as **PROVEN HEALTHY**, **PROVEN BROKEN**, **INFERENCE**, **HYPOTHESIS** and **UNKNOWN**. Simulated outputs cannot prove any real fault.

## 10. References

- [Primary SOP](./vm-build-failure.md)
- [RHOSO command contexts and caveats](https://github.com/sheejithkv/RHOSO/blob/main/docs/00-usage-and-conventions.md)
- [Official Red Hat sources](https://github.com/sheejithkv/RHOSO/blob/main/docs/official-sources.md)

## 11. Revision history

| Version | Date (UTC) | Change | Real-cluster test |
| :--- | :--- | :--- | :--- |
| 0.1.0 | 2026-10-21 | First simulated training example | Not performed |
