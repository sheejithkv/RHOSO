# 11. KEYSTONE IDENTITY, ACCESS AND RBAC

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Never put passwords in command arguments or shell history. Prefer clouds.yaml configured through an approved secret store and system-scoped audit roles where supported by deployment policy.

# [OS][RO] List users
openstack user list

# [OS][RO] Inspect user and disabled state
openstack user show "${USER_ID}"

# [OS][RO] List projects
openstack project list

# [OS][RO] Inspect project
openstack project show "${PROJECT_ID}"

# [OS][RO] List domains
openstack domain list

# [OS][RO] List groups
openstack group list

# [OS][RO] List role definitions
openstack role list

# [OS][RO] Inspect effective role grants with names
openstack role assignment list --names

# [OS][RO] Inspect system scoped administrative role assignments
openstack role assignment list --names --system all

# [OS][RO] Inspect grants on project
openstack role assignment list --names --project "${PROJECT_ID}"

# [OS][RO] List service catalog
openstack catalog list

# [OS][RO] List service registrations
openstack service list

# [OS][RO] List registered endpoints
openstack endpoint list

# [OS][RO] Inspect current token expiry WITHOUT token ID
openstack token issue -f value -c expires

# [OS][RO] Inspect application credential definitions where policy permits
openstack application credential list

# [OS][RO] Check selected project quotas
openstack quota show "${PROJECT_ID}"

# [OS][CHANGE] Create Keystone project (approved project governance required)
openstack project create --domain "${DOMAIN}" "${PROJECT_NAME}"

# [OS][CHANGE] Create role for preapproved RBAC design
openstack role create "${ROLE_NAME}"

# [OS][CHANGE] Assign approved role to project member
openstack role add --project "${PROJECT_ID}" --user "${USER_ID}" "${ROLE_NAME}"

# [OS][CHANGE] Disable compromised Keystone user with incident approval
openstack user set --disable "${USER_ID}"

# [OS][CHANGE] Enable user after investigation
openstack user set --enable "${USER_ID}"

# [OS][CHANGE] Disable project after impact review
openstack project set --disable "${PROJECT_ID}"

# [OS][CHANGE] Reenable project after resolution
openstack project set --enable "${PROJECT_ID}"

# [OS][CHANGE] Register new custom service type ONLY after authoritative service catalog ownership confirmed (may be Operator reconciled)
openstack service create --name "${SERVICE_NAME}" --description "${SERVICE_DESCRIPTION}" "${SERVICE_TYPE}"

# [OS][CHANGE] Register custom public API endpoint ONLY after checking Operator authoritative service registration
openstack endpoint create --region "${REGION}" "${SERVICE_TYPE}" public "${SERVICE_PUBLIC_URL}"

# [OS][RO] Inspect service registration command syntax
openstack service create --help

# [OS][RO] Inspect endpoint registration command syntax
openstack endpoint create --help

# [OS][UNVERIFIED] List registered optional Load Balancing API resources if Octavia deployed
openstack loadbalancer list

# [OS][UNVERIFIED] List registered optional Manila shares if Manila deployed
openstack share list

# [OS][UNVERIFIED] List registered optional Designate zones if Designate deployed
openstack zone list

# [OS][UNVERIFIED] List registered optional Barbican secrets if Barbican deployed
openstack secret list

# [OS][UNVERIFIED] List registered optional Ironic bare-metal nodes if Ironic deployed
openstack baremetal node list

# [OS][UNVERIFIED] List registered optional Heat stacks if Heat deployed
openstack stack list

# [OS][RO] Discover service-specific optional client subcommands
openstack --help | grep -E "(loadbalancer|share|zone|secret|baremetal|stack)"
```