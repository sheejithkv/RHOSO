# 06. NEUTRON NETWORK ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Provider network creation requires physnet->bridge mappings, upstream VLAN/L2 reachability and IPAM approval. Agents list in OVN deployments may not show every distributed function; correlate Neutron ports with OVN SB chassis and bindings.

# [OS][RO] Inspect network-agent state
openstack network agent list

# [OS][RO] Inspect selected agent record
openstack network agent show "${AGENT_ID}"

# [OS][RO] List networks and IDs
openstack network list --long

# [OS][RO] Inspect network provider segmentation, MTU and flags
openstack network show "${NETWORK}" -f yaml

# [OS][RO] List subnets
openstack subnet list --long

# [OS][RO] Inspect subnet DHCP, DNS and routes
openstack subnet show "${SUBNET}" -f yaml

# [OS][RO] List routers
openstack router list --long

# [OS][RO] Inspect router gateway and attached ports
openstack router show "${ROUTER}" -f yaml

# [OS][RO] List ports including binding host
openstack port list --long

# [OS][RO] Inspect binding details, security settings and allowed pairs
openstack port show "${PORT_ID}" -f yaml

# [OS][RO] List floating IPs
openstack floating ip list --long

# [OS][RO] Inspect selected floating IP mapping
openstack floating ip show "${FLOATING_IP_ID}" -f yaml

# [OS][RO] List network security groups
openstack security group list

# [OS][RO] List individual security group rules
openstack security group rule list "${SECURITY_GROUP}"

# [OS][RO] Inspect network QoS policies
openstack network qos policy list

# [OS][RO] Inspect QoS rules on policy
openstack network qos rule list "${QOS_POLICY}"

# [OS][RO] List RBAC grants to shared networks
openstack network rbac list

# [OS][RO] Inspect network RBAC record
openstack network rbac show "${RBAC_ID}"

# [OS][RO] List trunk ports (extension required)
openstack network trunk list

# [OS][RO] Inspect trunk children
openstack network trunk show "${TRUNK_ID}"

# [OS][RO] List network segments (extension required)
openstack network segment list

# [OS][RO] Inspect network availability zones
openstack availability zone list --network

# [EDPM][RO] Verify interface MTU on compute host
ip link show "${NIC}"

# [OS][RO] Inspect per-network DHCP settings
openstack subnet show "${TENANT_SUBNET}" -c enable_dhcp -c dns_nameservers -c host_routes

# [EDPM][RO] Read metadata agent/OVN metadata logs from discovered podman container
sudo podman logs --since 30m "${OVN_METADATA_CONTAINER}"

# [OS][CHANGE] Create provider flat network only if physnet bridge mappings validated
openstack network create --external --provider-network-type flat --provider-physical-network "${PHYSNET}" "${EXTERNAL_NETWORK_NAME}"

# [OS][CHANGE] Create provider VLAN network only if upstream VLAN approved
openstack network create --external --provider-network-type vlan --provider-physical-network "${PHYSNET}" --provider-segment "${VLAN_ID}" "${EXTERNAL_NETWORK_NAME}"

# [OS][CHANGE] Create external subnet with approved allocation pool
openstack subnet create --network "${EXTERNAL_NETWORK_NAME}" --subnet-range "${EXTERNAL_NETWORK_CIDR}" --gateway "${EXTERNAL_GATEWAY}" --allocation-pool "start=${EXTERNAL_POOL_START},end=${EXTERNAL_POOL_END}" --no-dhcp "${EXTERNAL_SUBNET_NAME}"

# [OS][CHANGE] Create project overlay network using configured ML2 default type
openstack network create "${TENANT_NETWORK_NAME}"

# [OS][CHANGE] Create tenant subnet with DHCP and DNS
openstack subnet create --network "${TENANT_NETWORK_NAME}" --subnet-range "${PRIVATE_NETWORK_CIDR}" --dns-nameserver "${DNS_SERVER}" "${TENANT_SUBNET_NAME}"

# [OS][CHANGE] Create project router
openstack router create "${ROUTER_NAME}"

# [OS][CHANGE] Attach tenant subnet to router
openstack router add subnet "${ROUTER_NAME}" "${TENANT_SUBNET_NAME}"

# [OS][CHANGE] Set external router gateway after provider path is verified
openstack router set --external-gateway "${EXTERNAL_NETWORK_NAME}" "${ROUTER_NAME}"

# [OS][CHANGE] Create security group for test workload
openstack security group create "${SECURITY_GROUP}"

# [OS][CHANGE] Permit ICMP ingress from approved probe CIDR only
openstack security group rule create --ingress --protocol icmp --remote-ip "${AUTHORIZED_SOURCE_CIDR}" "${SECURITY_GROUP}"

# [OS][CHANGE] Permit SSH ingress from approved probe CIDR only
openstack security group rule create --ingress --protocol tcp --dst-port 22 --remote-ip "${AUTHORIZED_SOURCE_CIDR}" "${SECURITY_GROUP}"

# [OS][CHANGE] Allocate floating IP from provider network
openstack floating ip create "${EXTERNAL_NETWORK_NAME}"

# [OS][CHANGE] Associate floating IP with one VM
openstack server add floating ip "${VM}" "${FLOATING_IP_ADDRESS}"

# [OS][RO] Inspect public/provider network and segmentation
openstack network show "${EXTERNAL_NETWORK_NAME}" -f yaml

# [OS][CHANGE] Create Neutron port on tenant network with approved security group
openstack port create --network "${TENANT_NETWORK_NAME}" --security-group "${SECURITY_GROUP}" "${PORT_NAME}"

# [OS][CHANGE] Add approved allowed-address-pairs on specified port
openstack port set --allowed-address ip-address="${ALLOWED_IP}" "${PORT_ID}"

# [OS][CHANGE] Disable port security only after an explicit risk acceptance
openstack port set --disable-port-security "${PORT_ID}"

# [OS][CHANGE] Create scoped network QoS policy
openstack network qos policy create "${QOS_POLICY}"

# [OS][CHANGE] Add egress bandwidth limit; validate QoS backend capability
openstack network qos rule create --type bandwidth-limit --max-kbps "${MAX_KBPS}" --egress "${QOS_POLICY}"

# [OS][CHANGE] Create network RBAC shared access grant to approved project
openstack network rbac create --type network --action access_as_shared --target-project "${TARGET_PROJECT_ID}" "${NETWORK}"

# [OS][CHANGE] Create trunk with pre-existing parent port; extension required
openstack network trunk create --parent-port "${PARENT_PORT_ID}" "${TRUNK_NAME}"
```