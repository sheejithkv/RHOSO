# 01. OPENSHIFT CLUSTER ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Contexts: [OCP] workstation with oc cluster credentials; [OS] OpenStackClient container; [EDPM] RHEL data plane host; [CEPH] Ceph admin; [POD] selected service container. [RO]=read-only; [CHANGE]=state change; [DELETE]=destructive; [UNVERIFIED]=locally confirm before use. All angle-bracket fields and shell variables require operator-supplied values. Read-only means no intended infrastructure state change, not zero logging or token issuance.

# [OCP][RO] Authenticate through configured cluster identity provider; use interactive auth and do not embed passwords
oc login "${OCP_API_URL}"

# [OCP][RO] Current OpenShift identity and selected server
oc whoami && oc whoami --show-server

# [OCP][RO] Identify selected project
oc project -q

# [OCP][RO] Inspect cluster version
oc get clusterversion -o wide

# [OCP][RO] Inspect operator readiness and degradation
oc get clusteroperators

# [OCP][RO] Inspect cluster node inventory
oc get nodes -o wide

# [OCP][RO] Inspect all node condition transitions
oc get nodes -o json | jq -r '.items[] | [.metadata.name,((.status.conditions // [])|map(select(.type=="Ready"))|.[0].status),((.status.conditions // [])|map(select(.type=="Ready"))|.[0].lastTransitionTime)]|@tsv'

# [OCP][RO] Review node allocatable resources
oc describe node "${OCP_NODE}"

# [OCP][RO] Inspect nodes resource pressure
oc adm top nodes

# [OCP][RO] Inspect node labels
oc get nodes --show-labels

# [OCP][RO] Inspect node taints
oc get nodes -o custom-columns=NODE:.metadata.name,TAINTS:.spec.taints

# [OCP][RO] List MachineConfigPools
oc get machineconfigpools

# [OCP][RO] Review MCP update/degraded conditions
oc describe mcp "${MCP_NAME}"

# [OCP][RO] List MachineConfigs
oc get machineconfigs

# [OCP][RO] List MachineSets, where Machine API is installed
oc get machinesets -A

# [OCP][RO] List MachineHealthChecks, where installed
oc get machinehealthchecks -A

# [OCP][RO] Get latest cluster events
oc get events -A --sort-by=.lastTimestamp

# [OCP][RO] Get pods with node placement
oc get pods -A -o wide

# [OCP][RO] Find non-running pod phases (includes Completed)
oc get pods -A --field-selector=status.phase!=Running

# [OCP][RO] List Pending pods
oc get pods -A --field-selector=status.phase=Pending

# [OCP][RO] Detect CrashLoopBackOff waiting reason
oc get pods -A -o json | jq -r '.items[] | select(any(.status.containerStatuses[]?; .state.waiting.reason=="CrashLoopBackOff")) | [.metadata.namespace,.metadata.name]|@tsv'

# [OCP][RO] Detect most recent OOMKilled termination
oc get pods -A -o json | jq -r '.items[] | select(any(.status.containerStatuses[]?; .lastState.terminated.reason=="OOMKilled" or .state.terminated.reason=="OOMKilled")) | [.metadata.namespace,.metadata.name]|@tsv'

# [OCP][RO] Read scoped pod events and container states
oc describe pod -n "${NS}" "${POD}"

# [OCP][RO] Review current pod resource usage
oc adm top pods -A --containers

# [OCP][RO] List Services and Routes
oc get services,routes -A

# [OCP][RO] List EndpointSlices and owning service labels
oc get endpointslices -A --show-labels

# [OCP][RO] List NetworkPolicies
oc get networkpolicies -A

# [OCP][RO] List PersistentVolumes
oc get pv -o wide

# [OCP][RO] List PersistentVolumeClaims
oc get pvc -A

# [OCP][RO] List StorageClasses
oc get storageclasses

# [OCP][RO] List namespace quotas and limits
oc get resourcequotas,limitranges -A

# [OCP][RO] List disruption budgets
oc get pdb -A

# [OCP][RO] List cluster networks
oc get network.config.openshift.io cluster -o yaml

# [OCP][RO] List Network Operators
oc get network.operator.openshift.io cluster -o yaml

# [OCP][RO] Find Multus DaemonSet and pods
oc get daemonsets,pods -A -l app=multus

# [OCP][RO] Discover NMState CRDs before querying
oc api-resources --api-group=nmstate.io

# [OCP][RO] List NodeNetworkState objects, if NMState installed
oc get nodenetworkstates -A

# [OCP][RO] List NodeNetworkConfigurationPolicies, if installed
oc get nncp

# [OCP][RO] List NMState enactments, if installed
oc get nnce -A

# [OCP][RO] List NetworkAttachmentDefinitions
oc get network-attachment-definitions.k8s.cni.cncf.io -A

# [OCP][RO] Inspect a Multus attachment definition
oc get network-attachment-definition "${NAD}" -n "${NS}" -o yaml

# [OCP][RO] Inspect OpenShift DNS config
oc get dns.operator/default -o yaml

# [OCP][RO] Inspect Cluster DNS configuration
oc get dns.config/cluster -o yaml

# [OCP][RO] Resolve service DNS inside an authorized running diagnostic container; specify its actual name
oc exec -n "${NS}" "${DIAGNOSTIC_POD}" -c "${CONTAINER}" -- getent hosts "${SERVICE_FQDN}"

# [OCP][RO] Test in-cluster HTTPS endpoint TLS and response using curl if installed
oc exec -n "${NS}" "${DIAGNOSTIC_POD}" -c "${CONTAINER}" -- curl --fail --show-error --silent --max-time 10 --output /dev/null --write-out "%{http_code} %{time_total}\n" "${API_URL}"
```