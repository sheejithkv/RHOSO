# 19. END-TO-END TEST VM PROVISIONING

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# APPROVED TEST ONLY. PRECONDITIONS: owner authorizes billable resources and provider IP/VLAN, physical bridge mapping, CIDR disjointness, DNS, SSH source CIDR, project quotas, cloud image URL + expected SHA256. Use separate OpenStackClient FS for file upload; do not assume OCP workstation file exists in pod. Commands here are individual [CHANGE]/[DELETE] steps, NOT auto-run. By default REUSE existing external network; provider creation is optional and must be skipped if it exists.

# [OCP][RO] Discover control plane and OpenStackClient pod
oc get openstackcontrolplane -A && oc get pods -n "${NS}" | grep -i openstackclient

# [OCP][RO] Open authenticated OpenStackClient session
oc rsh -n "${NS}" "${OS_CLIENT_POD}"

# [OS][RO] Verify Keystone token without printing token
openstack token issue -f value -c expires

# [OS][RO] Verify service catalog
openstack service list && openstack endpoint list

# [OS][RO] Verify Nova host and service health
openstack hypervisor list && openstack compute service list

# [OCP][RO] Verify Nova cell mappings from discovered conductor
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts

# [OS][RO] Verify Neutron API/agents
openstack network list && openstack network agent list

# [OS][CHANGE] Set test variables to actual approved values; example only, never execute unchanged
export EXTERNAL_NETWORK_NAME="<approved-external-network>" EXTERNAL_SUBNET_NAME="<external-subnet>" EXTERNAL_NETWORK_CIDR="<approved-external-cidr>" EXTERNAL_GATEWAY="<gateway-ip>" EXTERNAL_POOL_START="<first-usable-ip>" EXTERNAL_POOL_END="<last-usable-ip>" DNS_SERVER="<dns-ip>" PHYSNET="<mapped-physnet>"

# [OS][CHANGE] Define tenant/test names and approved host/cidr values
export TENANT_NETWORK_NAME="<tenant-network>" TENANT_SUBNET_NAME="<tenant-subnet>" PRIVATE_NETWORK_CIDR="<tenant-cidr>" ROUTER_NAME="<router>" SECURITY_GROUP="<sg>" AUTHORIZED_SOURCE_CIDR="<approved-source-cidr>" IMAGE_NAME="<image-name>" VM="<vm-name>" FLAVOR="<flavor-name>" KEYPAIR="<keypair-name>"

# [OS][CHANGE] Define approved sizing and guest login values before provisioning (no guessed production sizes)
export VCPU_COUNT="<approved-vcpu-count>" RAM_MIB="<approved-ram-mib>" DISK_GIB="<approved-root-disk-gib>" GUEST_USER="<published-image-login-user>"

# [OS][CHANGE] Define optional Cinder test volume information; skip Cinder section if no approved backend
export VOLUME_SIZE_GIB="<approved-size-gib>" VOLUME_TYPE="<approved-volume-type>" VOLUME_NAME="<test-volume-name>"

# [OS][RO] Validate no variable placeholder or blank remains before ANY change
( for v in EXTERNAL_NETWORK_NAME EXTERNAL_SUBNET_NAME EXTERNAL_NETWORK_CIDR EXTERNAL_GATEWAY EXTERNAL_POOL_START EXTERNAL_POOL_END DNS_SERVER PRIVATE_NETWORK_CIDR AUTHORIZED_SOURCE_CIDR PHYSNET TENANT_NETWORK_NAME TENANT_SUBNET_NAME ROUTER_NAME SECURITY_GROUP VM FLAVOR KEYPAIR IMAGE_NAME VCPU_COUNT RAM_MIB DISK_GIB GUEST_USER; do x="${!v-}"; [[ -n "$x" && "$x" != *"<"* && "$x" != *">"* ]] || { printf "BLOCKED: invalid/placeholder variable: %s\n" "$v" >&2; exit 1; }; done; echo "PREFLIGHT PASS: required variables populated; verify CIDR, gateway, physical mappings, quotas and ownership independently" )

# [OS][RO] Validate proposed CIDRs/pool/gateway and reject overlaps and invalid sizing (Python available in OpenStackClient image; no changes)
python3 - <<'PY_RHOSO_PREFLIGHT'
import ipaddress, os, sys
try:
    external = ipaddress.ip_network(os.environ['EXTERNAL_NETWORK_CIDR'], strict=False)
    private = ipaddress.ip_network(os.environ['PRIVATE_NETWORK_CIDR'], strict=False)
    source = ipaddress.ip_network(os.environ['AUTHORIZED_SOURCE_CIDR'], strict=False)
    gateway = ipaddress.ip_address(os.environ['EXTERNAL_GATEWAY'])
    pool_first = ipaddress.ip_address(os.environ['EXTERNAL_POOL_START'])
    pool_last = ipaddress.ip_address(os.environ['EXTERNAL_POOL_END'])
    dns = ipaddress.ip_address(os.environ['DNS_SERVER'])
    assert all(a.version == external.version for a in (gateway, pool_first, pool_last)), 'address family mismatch'
    assert all(a in external for a in (gateway, pool_first, pool_last)), 'gateway/pool outside provider CIDR'
    assert int(pool_first) <= int(pool_last), 'invalid pool range'
    assert not any(a in (pool_first, pool_last) for a in [gateway]), 'gateway overlaps pool boundary; inspect entire pool'
    assert not external.overlaps(private), 'provider and tenant CIDRs overlap'
    assert all(int(os.environ[v]) > 0 for v in ('VCPU_COUNT', 'RAM_MIB', 'DISK_GIB')), 'nonpositive flavor sizing'
    print('PREFLIGHT PASS: CIDR syntax, ranges, overlap and positive size; still validate actual gateway, DNS reachability and physnet')
except (KeyError, ValueError, AssertionError) as exc:
    print(f'BLOCKED: preflight: {exc}', file=sys.stderr)
    raise SystemExit(1)
PY_RHOSO_PREFLIGHT

# [OS][RO] Check whether requested external network already exists
openstack network show "${EXTERNAL_NETWORK_NAME}" -f yaml

# [OS][CHANGE] Optionally CREATE flat provider external network only if none exists and physical L2 configured
openstack network create --external --provider-network-type flat --provider-physical-network "${PHYSNET}" "${EXTERNAL_NETWORK_NAME}"

# [OS][CHANGE] Alternative external VLAN network ONLY if approved VLAN mapping is deployed (do NOT create both)
openstack network create --external --provider-network-type vlan --provider-physical-network "${PHYSNET}" --provider-segment "${VLAN_ID}" "${EXTERNAL_NETWORK_NAME}"

# [OS][CHANGE] Optionally create subnet only on newly created external network
openstack subnet create --network "${EXTERNAL_NETWORK_NAME}" --subnet-range "${EXTERNAL_NETWORK_CIDR}" --gateway "${EXTERNAL_GATEWAY}" --allocation-pool "start=${EXTERNAL_POOL_START},end=${EXTERNAL_POOL_END}" --no-dhcp "${EXTERNAL_SUBNET_NAME}"

# [OS][CHANGE] Create tenant network in chosen project
openstack network create "${TENANT_NETWORK_NAME}"

# [OS][CHANGE] Create tenant DHCP subnet
openstack subnet create --network "${TENANT_NETWORK_NAME}" --subnet-range "${PRIVATE_NETWORK_CIDR}" --dns-nameserver "${DNS_SERVER}" "${TENANT_SUBNET_NAME}"

# [OS][CHANGE] Create router
openstack router create "${ROUTER_NAME}"

# [OS][CHANGE] Add tenant subnet to router
openstack router add subnet "${ROUTER_NAME}" "${TENANT_SUBNET_NAME}"

# [OS][CHANGE] Bind approved external network gateway
openstack router set --external-gateway "${EXTERNAL_NETWORK_NAME}" "${ROUTER_NAME}"

# [OS][CHANGE] Create dedicated security group
openstack security group create "${SECURITY_GROUP}"

# [OS][CHANGE] Allow ICMP from authorized test location
openstack security group rule create --ingress --protocol icmp --remote-ip "${AUTHORIZED_SOURCE_CIDR}" "${SECURITY_GROUP}"

# [OS][CHANGE] Allow SSH only from approved source
openstack security group rule create --ingress --protocol tcp --dst-port 22 --remote-ip "${AUTHORIZED_SOURCE_CIDR}" "${SECURITY_GROUP}"

# [OCP][CHANGE] Set secure workstation-private key location to approved absolute path before ssh-keygen
export PRIVATE_KEY_PATH="<absolute-workstation-private-key-path>"

# [OCP][CHANGE] Create SSH key on SECURE workstation, not from a production shared shell
ssh-keygen -t ed25519 -a 64 -f "${PRIVATE_KEY_PATH}" -C "${KEYPAIR}"

# [OCP][CHANGE] Restrict private-key file permissions
chmod 600 "${PRIVATE_KEY_PATH}"

# [OCP][RO] Verify OpenStackClient actual namespace/pod/container before staging ONLY public key
oc get pod -n "${NS}" "${OS_CLIENT_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][CHANGE] Copy only public key into ephemeral OpenStackClient container (NOT private key)
oc cp "${PRIVATE_KEY_PATH}.pub" "${NS}/${OS_CLIENT_POD}:/tmp/${KEYPAIR}.pub" -c "${OS_CLIENT_CONTAINER}"

# [OS][CHANGE] Set staged public key path in selected OpenStackClient shell
export PUBLIC_KEY_PATH="/tmp/${KEYPAIR}.pub"

# [OS][CHANGE] Import staged public key after confirming project identity
openstack keypair create --public-key "${PUBLIC_KEY_PATH}" "${KEYPAIR}"

# [OS][CHANGE] Create test flavor with approved CPU/RAM/disk sizing variables
openstack flavor create --vcpus "${VCPU_COUNT}" --ram "${RAM_MIB}" --disk "${DISK_GIB}" "${FLAVOR}"

# [OCP][CHANGE] Define approved image source and vendor SHA256 from trusted publisher
export IMAGE_URL="<trusted-image-url>" IMAGE_SHA256="<publisher-sha256>" IMAGE_FILE="<local-qcow2-path>"

# [OCP][CHANGE] Download authorized image from vendor; TLS verification enabled
curl --fail --location --show-error --output "${IMAGE_FILE}" "${IMAGE_URL}"

# [OCP][RO] Verify image SHA256 against independent published digest
printf "%s  %s\n" "${IMAGE_SHA256}" "${IMAGE_FILE}" | sha256sum -c -

# [OCP][RO] Inspect image file type and qcow2 metadata
file "${IMAGE_FILE}" && qemu-img info "${IMAGE_FILE}"

# [OCP][RO] Derive deterministic image staging basename
IMAGE_BASENAME=$(basename -- "${IMAGE_FILE}")

# [OCP][CHANGE] Securely stage tested image in OpenStackClient pod; this writes only to pod filesystem
oc cp "${IMAGE_FILE}" "${NS}/${OS_CLIENT_POD}:/tmp/${IMAGE_BASENAME}" -c "${OS_CLIENT_CONTAINER}"

# [OS][CHANGE] Upload staged image to Glance from OpenStackClient
openstack image create --private --disk-format qcow2 --container-format bare --file "/tmp/${IMAGE_BASENAME}" "${IMAGE_NAME}"

# [OS][RO] Verify Glance image ACTIVE and properties
openstack image show "${IMAGE_NAME}" -f yaml

# [OS][CHANGE] Boot VM with managed tenant network and approved security group
openstack server create --image "${IMAGE_NAME}" --flavor "${FLAVOR}" --network "${TENANT_NETWORK_NAME}" --security-group "${SECURITY_GROUP}" --key-name "${KEYPAIR}" "${VM}"

# [OS][RO] Poll Nova server API for ACTIVE/ERROR for up to 600 seconds; not proof that cloud-init or SSH is ready
for i in {1..60}; do VM_STATE=$(openstack server show "${VM}" -f value -c status) || break; [[ "$VM_STATE" == ACTIVE || "$VM_STATE" == ERROR ]] && break; sleep 10; done; printf "VM state: %s\n" "$VM_STATE"

# [OS][RO] Require Nova ACTIVE before any floating-IP or attachment changes; investigate ERROR rather than forcing state
[[ "${VM_STATE}" == ACTIVE ]] || { printf "BLOCKED: VM state=%s, inspect Nova and console logs\n" "${VM_STATE}" >&2; false; }

# [OS][RO] Verify instance status and selected compute host
openstack server show "${VM}" -f yaml

# [OS][RO] Inspect VM binding port
openstack port list --server "${VM}"

# [OS][RO] Verify DHCP-enabled subnet and DNS
openstack subnet show "${TENANT_SUBNET_NAME}" -f yaml

# [OS][RO] Read guest console output for boot/cloud-init failures
openstack console log show "${VM}"

# [OS][CHANGE] Allocate floating IP from approved provider pool; capture result rather than guessing address
FLOATING_IP_ADDRESS=$(openstack floating ip create "${EXTERNAL_NETWORK_NAME}" -f value -c floating_ip_address)

# [OS][RO] Verify floating IP was allocated successfully before association
[[ -n "${FLOATING_IP_ADDRESS}" ]] && openstack floating ip show "${FLOATING_IP_ADDRESS}" -f yaml

# [OS][CHANGE] Associate the allocated IP with the test VM
openstack server add floating ip "${VM}" "${FLOATING_IP_ADDRESS}"

# [OS][RO] Check VM FIP mapping
openstack floating ip show "${FLOATING_IP_ADDRESS}" -f yaml

# [OCP][RO] Test ICMP from approved external source
ping -c 4 -W 2 "${FLOATING_IP_ADDRESS}"

# [OCP][RO] Test SSH from authorized location; known_hosts validation must not be bypassed
ssh -i "${PRIVATE_KEY_PATH}" "${GUEST_USER}@${FLOATING_IP_ADDRESS}" true

# [OS][RO] Inspect Nova, Neutron and OVN mapping
openstack server show "${VM}" -c status -c addresses -c OS-EXT-SRV-ATTR:host && openstack port list --server "${VM}"

# [OCP][RO] Verify actual logical switches after selecting matching NB pod
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show

# [OCP][RO] Verify actual port binding after selecting matching SB pod
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Port_Binding

# [EDPM][RO] Check provider bridge and datapath path on actual gateway EDPM node
sudo ovs-vsctl show

# [OS][CHANGE] Optional create block volume of approved type and size
openstack volume create --size "${VOLUME_SIZE_GIB}" --type "${VOLUME_TYPE}" "${VOLUME_NAME}"

# [OS][CHANGE] Optional attach volume when available
openstack server add volume "${VM}" "${VOLUME_NAME}"

# [OS][RO] Optional verify volume attachment from both services
openstack server volume list "${VM}" && openstack volume show "${VOLUME_NAME}"

# [OS][DELETE] CLEANUP: detach optional volume after guest filesystem unmount
openstack server remove volume "${VM}" "${VOLUME_NAME}"

# [OS][DELETE] CLEANUP: delete test instance after workload owner approval
openstack server delete "${VM}"

# [OS][DELETE] CLEANUP: release floating IP after VM association removed
openstack floating ip delete "${FLOATING_IP_ADDRESS}"

# [OS][DELETE] CLEANUP: delete optional test volume after verified detached
openstack volume delete "${VOLUME_NAME}"

# [OS][DELETE] CLEANUP: delete router subnet interface before router
openstack router remove subnet "${ROUTER_NAME}" "${TENANT_SUBNET_NAME}"

# [OS][CHANGE] CLEANUP: detach external router gateway (required before removing router)
openstack router unset --external-gateway "${ROUTER_NAME}"

# [OS][DELETE] CLEANUP: delete test router
openstack router delete "${ROUTER_NAME}"

# [OS][DELETE] CLEANUP: remove tenant subnet
openstack subnet delete "${TENANT_SUBNET_NAME}"

# [OS][DELETE] CLEANUP: remove tenant network
openstack network delete "${TENANT_NETWORK_NAME}"

# [OS][DELETE] CLEANUP: remove dedicated security group
openstack security group delete "${SECURITY_GROUP}"

# [OS][DELETE] CLEANUP: remove public key record (not local private key)
openstack keypair delete "${KEYPAIR}"

# [OS][DELETE] CLEANUP: remove test image only when no consumers remain
openstack image delete "${IMAGE_NAME}"

# [OS][DELETE] CLEANUP: remove test flavor after instance deletion
openstack flavor delete "${FLAVOR}"

# [OS][DELETE] CLEANUP: do not delete shared/preexisting external network; if created solely for lab, delete subnet then network after verifying no consumers
openstack subnet delete "${EXTERNAL_SUBNET_NAME}" && openstack network delete "${EXTERNAL_NETWORK_NAME}"
```