# 04. OPENSTACK CLIENT AND API ACCESS

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# [OCP][RO] Discover actual container name in selected OpenStackClient pod
oc get pod -n "${NS}" "${OS_CLIENT_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# Red Hat documented default: oc rsh -n openstack openstackclient. For nondefault namespace use $NS; do not rely on a workstation OpenStack CLI. Credentials are provisioned in OpenStackClient; do not print environment variables or tokens.

# [OCP][RO] Discover OpenStackClient pod in selected RHOSO namespace
oc get pods -n "${NS}" -o wide | grep -Ei "^openstackclient[[:space:]-]"

# [OCP][RO] Access documented default client interactively
oc rsh -n openstack openstackclient

# [OCP][RO] Access discovered client and container interactively
oc rsh -n "${NS}" -c "${OS_CLIENT_CONTAINER}" "${OS_CLIENT_POD}"

# [OCP][RO] Run version check from OCP without printing credentials
oc exec -n "${NS}" "${OS_CLIENT_POD}" -c "${OS_CLIENT_CONTAINER}" -- openstack --version

# [OS][RO] Validate token issuance without exposing token
openstack token issue -f value -c expires

# [OS][RO] Inspect service catalog
openstack catalog list

# [OS][RO] Inspect registered services
openstack service list

# [OS][RO] Inspect API endpoint registration
openstack endpoint list

# [OS][RO] Inspect accessible regions
openstack region list

# [OS][RO] Identify scoped authentication using nonsecret fields
openstack configuration show --mask

# [OS][RO] Discover CLI extensions and subcommands
openstack --help

# [OS][RO] Discover optional service-specific command flags
openstack server create --help

# [OS][RO] Read server API operations
openstack server list --limit 1

# [OS][RO] Read network API operations
openstack network list

# [OS][RO] Read image API operations
openstack image list

# [OS][RO] Read block storage API operations where enabled
openstack volume list
```