# 02. RHOSO OPERATORS AND CONTROL PLANE

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Discover namespaces and installed CRDs first. Optional service CRDs (Octavia/Manila/Designate/Barbican/Ironic/Heat/Horizon/Telemetry) depend on enabled operators and release. CR spec changes belong in authoritative GitOps/Helm/source manifests, not generated pods.

# [OCP][RO] Discover RHOSO control plane namespace(s)
oc get openstackcontrolplane -A

# [OCP][RO] Discover service API resources and CRDs
oc api-resources --verbs=list | grep -Ei "openstack|nova|neutron|glance|cinder|keystone|ovn|galera|rabbit|maria"

# [OCP][RO] Discover all RHOSO-related CRDs
oc get crd | grep -Ei "openstack|nova|neutron|glance|cinder|keystone|ovn|galera|rabbit|maria"

# [OCP][RO] Discover RHOSO Operators
oc get operators

# [OCP][RO] Discover OperatorSubscriptions
oc get subscriptions.operators.coreos.com -A

# [OCP][RO] Discover ClusterServiceVersions
oc get csv -A

# [OCP][RO] Discover InstallPlans
oc get installplans -A

# [OCP][RO] Discover operator deployments
oc get deployments -n "${OPERATORS_NS}"

# [OCP][RO] Review operator pod readiness
oc get pods -n "${OPERATORS_NS}" -o wide

# [OCP][RO] Review operator log errors from a selected deployment
oc logs -n "${OPERATORS_NS}" deployment/"${OPERATOR_DEPLOYMENT}" --since=30m --all-containers=true

# [OCP][RO] Inspect operator conditions
oc describe csv -n "${OPERATORS_NS}" "${CSV_NAME}"

# [OCP][RO] Inspect control plane spec, status and conditions
oc get openstackcontrolplane "${CONTROLPLANE_NAME}" -n "${NS}" -o yaml

# [OCP][RO] Read control plane readiness summary
oc get openstackcontrolplane -n "${NS}"

# [OCP][RO] List OpenStack service CRs currently installed in namespace
oc api-resources --namespaced=true --verbs=list -o name | grep -Ei "(keystone|nova|neutron|glance|cinder|placement|ovn|galera|rabbitmq|memcached|horizon|octavia|manila|designate|barbican|ironic|heat|telemetry)"

# [OCP][RO] List control plane deployments
oc get deployments,statefulsets,daemonsets -n "${NS}" -o wide

# [OCP][RO] List service pods and owning nodes
oc get pods -n "${NS}" -o wide --show-labels

# [OCP][RO] Inspect service endpoints and backend readiness
oc get services,endpointslices -n "${NS}" -o wide

# [OCP][RO] Inspect API routes
oc get routes -n "${NS}"

# [OCP][RO] Inspect TLS certificate status, if cert-manager installed
oc get certificates.cert-manager.io -n "${NS}"

# [OCP][RO] Inspect Secrets metadata only: NEVER retrieve .data
oc get secrets -n "${NS}" -o custom-columns=NAME:.metadata.name,TYPE:.type,CREATED:.metadata.creationTimestamp

# [OCP][RO] Inspect ConfigMap names and metadata without service credential values
oc get configmaps -n "${NS}" -o custom-columns=NAME:.metadata.name,CREATED:.metadata.creationTimestamp

# [OCP][RO] Inspect service pod controller ownerReferences
oc get pod -n "${NS}" "${POD}" -o jsonpath="{.metadata.ownerReferences}"

# [OCP][RO] Inspect StatefulSet ownerReferences
oc get statefulset -n "${NS}" "${STATEFULSET}" -o jsonpath="{.metadata.ownerReferences}"

# [OCP][RO] Inspect managed fields and field managers
oc get "${KIND}" "${RESOURCE}" -n "${NS}" -o json | jq '.metadata.managedFields|map({manager,operation,time})'

# [OCP][RO] Detect GitOps Application CRs (if installed)
oc get applications.argoproj.io -A

# [OCP][RO] Detect Argo CD ApplicationSet CRs (if installed)
oc get applicationsets.argoproj.io -A

# [OCP][RO] Detect Helm ownership on resource
oc get "${KIND}" "${RESOURCE}" -n "${NS}" -o json | jq '.metadata.annotations|with_entries(select(.key|test("meta.helm.sh")))'

# [OCP][RO] Find installed Helm releases (if helm configured)
helm list -A

# [OCP][RO] Inspect service-specific CR kind by exact name discovered from api-resources
oc get "${SERVICE_CR_KIND}" -n "${NS}" -o wide

# [OCP][RO] Inspect enabled services in operator-managed source spec
oc get openstackcontrolplane "${CONTROLPLANE_NAME}" -n "${NS}" -o json | jq '.spec|keys'
```