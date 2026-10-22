# RHOSO 18.x — Production Administration Reference

A command-first operational reference for **Red Hat OpenStack Services on OpenShift 18.0.x**, covering
OpenShift, Operators, EDPM, Nova cells, Placement, Neutron, OVN/OVS, Cinder/Ceph, Galera,
RabbitMQ, HA, forensic troubleshooting, planned maintenance, and recovery.

> **Important:** Reference commands are **not** a single executable installer or runbook.
> Many require privileged access and environment-specific variables. Review each tagged
> command before use. Not validated against a live RHOSO cluster.

## Start here

**[SOP catalogue and update instructions](SOP/README.md)** · [SOP template](SOP/TEMPLATE.md) · [MkDocs Material documentation](https://squidfunk.github.io/mkdocs-material/)


- [Standard Operating Procedures (SOP) and improvement proposals](SOP/README.md)
- [Execution contexts, prerequisites and verification limits](docs/00-usage-and-conventions.md)
- [Official Red Hat documentation](docs/official-sources.md)
- [Read-only daily health-check script](scripts/rhoso-healthcheck.sh)
- [Original consolidated runbook (plain text)](source/RHOSO_18x_Complete_Production_Runbook.txt)
- [Original command reference (plain text)](source/RHOSO_18x_Production_Administration_Reference.txt)

## Standard operating procedures

The [SOP directory](SOP/README.md) provides a [standard procedure template](SOP/TEMPLATE.md), [contribution/review process](SOP/CONTRIBUTING.md), four **DRAFT** operational procedures and a [prioritized improvement backlog](SOP/IMPROVEMENTS.md). SOP Markdown is the single source of truth; a MkDocs Material website is built automatically from it on pull requests and published to `gh-pages` after merge. GitHub Pages must be enabled once under repository Settings → Pages, selecting `gh-pages` / root. Procedures remain unapproved for production until tested and signed off for the deployed RHOSO version and topology. SOP changes use an accompanying [PR checklist](.github/PULL_REQUEST_TEMPLATE/sop-change.md).

## Administration reference — 21 sections

- [01. OPENSHIFT CLUSTER ADMINISTRATION](docs/01-openshift-cluster-administration.md)
- [02. RHOSO OPERATORS AND CONTROL PLANE](docs/02-rhoso-operators-and-control-plane.md)
- [03. RHOSO EDPM DATA PLANE ADMINISTRATION](docs/03-edpm-data-plane-administration.md)
- [04. OPENSTACK CLIENT AND API ACCESS](docs/04-openstack-client-api-access.md)
- [05. NOVA COMPUTE, CELLS AND PLACEMENT](docs/05-nova-cells-compute-placement.md)
- [06. NEUTRON NETWORK ADMINISTRATION](docs/06-neutron-network-administration.md)
- [07. OVN NORTHBOUND, SOUTHBOUND AND OPEN VSWITCH](docs/07-ovn-northbound-southbound-ovs.md)
- [08. CINDER BLOCK STORAGE ADMINISTRATION](docs/08-cinder-block-storage.md)
- [09. CEPH STORAGE ADMINISTRATION](docs/09-ceph-storage.md)
- [10. GLANCE IMAGE ADMINISTRATION](docs/10-glance-image-administration.md)
- [11. KEYSTONE IDENTITY, ACCESS AND RBAC](docs/11-keystone-identity-rbac.md)
- [12. RABBITMQ ADMINISTRATION](docs/12-rabbitmq-administration.md)
- [13. GALERA DATABASE ADMINISTRATION](docs/13-galera-database-administration.md)
- [14. HIGH AVAILABILITY ADMINISTRATION](docs/14-high-availability.md)
- [15. MONITORING AND OBSERVABILITY](docs/15-monitoring-observability.md)
- [16. LOGGING, FORENSIC TROUBLESHOOTING AND MUST-GATHER](docs/16-logging-troubleshooting.md)
- [17. COMPUTE MAINTENANCE AND CHANGE CONTROL](docs/17-compute-maintenance.md)
- [18. BACKUP, RESTORE AND DISASTER RECOVERY](docs/18-backup-disaster-recovery.md)
- [19. END-TO-END TEST VM PROVISIONING](docs/19-end-to-end-test-vm.md)
- [20. DAILY RHOSO OPERATIONAL HEALTH CHECK](docs/20-daily-operational-health-check.md)
- [21. COMMAND INDEX AND OPERATIONAL QUICK LISTS](docs/21-command-index-and-quick-lists.md)

## Run the health check

Requires an authenticated OpenShift CLI (`oc`) session, `jq`, and API permissions. A suitable
OpenStackClient pod is required for RHOSO API checks. Commands are read-only against infrastructure;
report files are generated locally with restrictive permissions.

```bash
# Authenticate first through your approved OpenShift identity provider.
oc whoami

# Validate script syntax locally.
bash -n scripts/rhoso-healthcheck.sh

# Run; set RHOSO_NAMESPACE explicitly when multiple RHOSO control planes exist.
RHOSO_NAMESPACE="<actual-rhoso-namespace>" bash scripts/rhoso-healthcheck.sh
```

**Exit codes:** `0` = implemented checks pass; `1` = warnings or unavailable checks;
`2` = definite failure or missing prerequisites. Inspect the timestamped report directory.
These outcomes are not equivalent to end-to-end RHOSO transaction validation.

## Status and safety

- Shell syntax of `scripts/rhoso-healthcheck.sh` was checked; no live cloud test was performed.
- The original reference contains `[RO]`, `[CHANGE]`, `[DELETE]`, and `[UNVERIFIED]` labels.
- Commands for Nova cell mapping and OpenStack resource provisioning can be state-changing;
  identify authoritative reconciler ownership and use formal change control.
- Control-plane backup/restore compatibility is release-gated: see
  [usage notes](docs/00-usage-and-conventions.md).
- This repository package **does not include credentials**, local diagnostics, cluster
  configuration exports, or personal kubeconfig files.

## Repository layout

```text
RHOSO/
├── README.md
├── SOP/                           # Sole maintained SOP Markdown source
├── mkdocs.yml                     # Navigation, layout and website configuration
├── requirements-docs.txt          # Pinned MkDocs build dependencies
├── docs/                          # 21 numbered Markdown reference sections
│   ├── 00-usage-and-conventions.md
│   └── official-sources.md
├── scripts/rhoso-healthcheck.sh   # Executable, read-only health check
├── source/                        # Unmodified original deliverables
└── .github/workflows/validate.yml # Syntax, documentation build and gh-pages publish
```

**Source reference preparation date:** 2026-10-20. **SOP scaffold date:** 2026-10-20. Check installed RHOSO minor/micro versions,
Operator versions and official Red Hat documentation for subsequent changes.