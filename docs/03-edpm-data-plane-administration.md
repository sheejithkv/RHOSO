# 03. RHOSO EDPM DATA PLANE ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# [OCP] manages data plane CRs and Ansible execution; [EDPM] host commands are run after approved SSH/access, not via oc exec into OCP node. A completed OpenStackDataPlaneDeployment does not automatically re-run after NodeSet edits.

# [OCP][RO] Discover NodeSets
oc get openstackdataplanenodesets -A

# [OCP][RO] Discover deployments
oc get openstackdataplanedeployments -A

# [OCP][RO] Discover DataPlaneService resources
oc get openstackdataplaneservices -A

# [OCP][RO] Discover OpenStackAnsibleEE resources
oc get openstackansibleee -A

# [OCP][RO] Inspect NodeSet configuration and host inventory
oc get openstackdataplanenodeset -n "${NS}" "${NODESET}" -o yaml

# [OCP][RO] Inspect deployment readiness conditions
oc get openstackdataplanedeployment -n "${NS}" "${DP_DEPLOYMENT}" -o yaml

# [OCP][RO] Find Ansible execution resources for deployment
oc get openstackansibleee -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"

# [OCP][RO] Find deployment Ansible Kubernetes Jobs
oc get jobs -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"

# [OCP][RO] Discover Ansible EE pods
oc get pods -n "${NS}" -l app=openstackansibleee -o wide

# [OCP][RO] Retrieve bounded Ansible logs for selected EE pod
oc logs -n "${NS}" "${ANSIBLE_POD}" --all-containers=true --since=60m

# [OCP][RO] Inspect failed Ansible job logs via Job controller
oc logs -n "${NS}" job/"${ANSIBLE_JOB}" --all-containers=true --since=60m

# [OCP][RO] Inspect SSH-related secret NAMES only
oc get secrets -n "${NS}" -o name | grep -Ei "ssh|edpm"

# [OCP][RO] Check approved EDPM SSH connectivity without altering host
ssh -o BatchMode=yes -o ConnectTimeout=5 "${EDPM_USER}@${EDPM_HOST}" true

# [EDPM][RO] Check RHEL identity and version
cat /etc/redhat-release && hostname -f

# [EDPM][RO] Discover failed systemd units
sudo systemctl --failed --no-pager

# [EDPM][RO] List service unit names
systemctl list-units --type=service --all --no-pager

# [EDPM][RO] Check discovered Nova Compute service status
sudo systemctl status "${NOVA_COMPUTE_UNIT}" --no-pager

# [EDPM][RO] Discover services related to OpenStack/OVN/libvirt
systemctl list-unit-files | grep -Ei "nova|ovn|ovs|virt|libvir|qemu"

# [EDPM][RO] List Podman containers
sudo podman ps -a --format "table {{.Names}} {{.Status}} {{.Image}}"

# [EDPM][RO] Read selected container log
sudo podman logs --since 30m "${CONTAINER}"

# [EDPM][RO] Find OVN and Nova processes
ps -eo pid,args | grep -Ei "[n]ova-compute|[o]vn-controller|[l]ibvirtd|[v]irtqemud"

# [EDPM][RO] Check KVM and virtualization modules
lsmod | grep -E "^(kvm|vfio)"

# [EDPM][RO] Inspect NUMA topology
lscpu -e=CPU,NODE,SOCKET,CORE,ONLINE

# [EDPM][RO] Inspect CPU NUMA node summary
numactl --hardware

# [EDPM][RO] Inspect hugepages and memory
grep -Ei "HugePages|Hugepagesize|MemTotal|MemAvailable" /proc/meminfo

# [EDPM][RO] Inspect CPU isolation and boot configuration
cat /proc/cmdline

# [EDPM][RO] Inspect isolated CPUs where configured
cat /sys/devices/system/cpu/isolated

# [EDPM][RO] List PCI NICs and accelerators
lspci -nn | grep -Ei "ethernet|network|vf|accelerator"

# [EDPM][RO] Inspect SR-IOV VF count (select interface)
cat "/sys/class/net/${NIC}/device/sriov_numvfs"

# [EDPM][RO] Inspect bound PCI drivers
lspci -nnk

# [EDPM][RO] Inspect DPDK NIC binding if tool installed
sudo dpdk-devbind.py --status

# [EDPM][RO] Inspect Linux interfaces and MTU
ip -details link show

# [EDPM][RO] Inspect VLAN interfaces
ip -d link show type vlan

# [EDPM][RO] Inspect bonding status if Linux bonding configured
cat "/proc/net/bonding/${BOND_NAME}"

# [EDPM][RO] Inspect IP addresses
ip -br address

# [EDPM][RO] Inspect routes and selected next-hop
ip route show table all

# [EDPM][RO] Inspect policy routing
ip rule show

# [EDPM][RO] Inspect DNS resolver state
resolvectl status

# [EDPM][RO] Inspect network profiles
nmcli connection show

# [EDPM][RO] Inspect NIC link
ethtool "${NIC}"

# [EDPM][RO] Inspect LACP/bond status where OVS bond used
sudo ovs-appctl bond/show

# [EDPM][RO] Inspect chrony synchronization
chronyc tracking && chronyc sources -v

# [EDPM][RO] Inspect filesystems and inodes
df -hT && df -i

# [EDPM][RO] Inspect recent kernel errors
sudo journalctl -k --since "1 hour ago" -p warning --no-pager

# [EDPM][RO] Inspect host OS and package versions
uname -r && rpm -q openstack-nova-compute ovn-host openvswitch --quiet; rpm -qa | grep -Ei "openstack-nova|ovn|openvswitch"
```