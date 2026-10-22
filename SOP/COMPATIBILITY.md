# RHOSO release and topology applicability register

**No target cluster version or topology was provided. Values below are UNKNOWN; no installation has been certified.**

| Component | Required deployment evidence | Verification |
| --- | --- | --- |
| RHOSO Operator/CRs | Exact RHOSO 18.0 maintenance release, Operator CSVs and deployed services | UNKNOWN |
| OpenShift | Cluster version, APIs, networking/monitoring and OADP compatibility | UNKNOWN |
| EDPM | RHEL version, node sets, execution environment, enabled services, cell mappings | UNKNOWN |
| Nova / Placement | Cells, compute hosts, traits, aggregates, storage and scheduler config | UNKNOWN |
| Neutron / OVN | Topology, NB/SB clusters, gateways, br-ex mappings, network types | UNKNOWN |
| Cinder / Ceph | Enabled drivers, Ceph/ODF/external backend model, replication/multipath | UNKNOWN |
| RabbitMQ / Galera | Controller/Operator ownership, pod selectors, cluster/SQL CLI context | UNKNOWN |
| Backup / DR | Supported RHOSO/OCP/OADP combination, RPO/RTO, isolated restore evidence | UNKNOWN |

**Mandatory:** Each SOP must specify the actual tested combination and Red Hat maintenance-release documentation before being promoted from DRAFT. RHOSO 18.0.21+ backup procedures have documented prerequisites; do not generalize them to all 18.x releases.

Official references: [RHOSO documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0), [release notes](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/release_notes/index).
