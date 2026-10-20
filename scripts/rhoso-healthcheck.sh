#!/usr/bin/env bash
# RHOSO 18.x read-only daily health check, 2026-10-20.
# Infrastructure operations: oc get / oc exec (read-only CLI) ONLY.
# Requires oc and jq. Optional RHOSO_NAMESPACE selects among multiple clouds.
# Status semantics: PASS = validated response + expected invariant; WARN = risk;
# FAIL = observed failed invariant; UNAVAILABLE = check cannot run or be proven.
# Files are local-only and mode 0600; report directory is mode 0700.
set -uo pipefail
umask 077
export LC_ALL=C
UTC=$(date -u +%Y%m%dT%H%M%SZ)
OUTDIR=${RHOSO_REPORT_DIR:-"$PWD/rhoso-health-$UTC"}
mkdir -p -- "$OUTDIR" || exit 2
chmod 700 "$OUTDIR"
SUMMARY="$OUTDIR/summary.tsv"
: > "$SUMMARY"
printf '# RHOSO 18.x report UTC=%s\n# Paths may contain internal topology metadata; protect files.\n' "$UTC"

record() { # severity, check name, safe detail
  local sev="$1" name="$2" msg="$3"
  msg=${msg//$'\t'/ }
  msg=${msg//$'\n'/ }
  printf '%s\t%s\t%s\n' "$sev" "$name" "$msg" >> "$SUMMARY"
  printf '%-11s %-30s %s\n' "$sev" "$name" "$msg"
}
run() { # files contain diagnostic output, never command lines or secrets
  local tag="$1"; shift
  "$@" > "$OUTDIR/$tag.out" 2> "$OUTDIR/$tag.err"
}
can_run() { command -v "$1" >/dev/null 2>&1; }
ocj() { oc "$@" -o json; }
js() { jq -er "$2" "$OUTDIR/$1.out" >/dev/null 2>&1; }
pass_rc() { # distinguish inaccessible components from a definitive failed invariant
  local tag="$1" title="$2"; shift 2
  if run "$tag" "$@"; then record PASS "$title" 'read-only API request successful'; return 0
  else record UNAVAILABLE "$title" "request failed; inspect ${tag}.err"; return 1; fi
}

if ! can_run oc; then record UNAVAILABLE prerequisites 'oc missing'; exit 2; fi
if ! can_run jq; then record UNAVAILABLE prerequisites 'jq missing'; exit 2; fi
if ! run oc-auth oc whoami; then record FAIL oc-login 'no active/authorized OpenShift session'; exit 2; fi
record PASS oc-login 'OpenShift CLI authenticated'

if run version oc get clusterversion -o json; then
  if js version '[.status.conditions[]? | select(.type=="Available") | .status] | any(.=="True")'; then
    record PASS oc-version 'ClusterVersion Available=True'
  else record WARN oc-version 'ClusterVersion Available not True or condition missing'; fi
else record UNAVAILABLE oc-version 'ClusterVersion unavailable'; fi
if run operators oc get clusteroperators -o json; then
  if js operators '(.items|length)>0 and ([.items[] | select(any(.status.conditions[]?; .type=="Degraded" and .status=="True") or (any(.status.conditions[]?; .type=="Available" and .status=="False")))] | length == 0)'; then
    record PASS clusteroperators 'no explicit Degraded=True or Available=False condition'
  else record FAIL clusteroperators 'one or more degraded/unavailable operators'; fi
else record UNAVAILABLE clusteroperators 'cannot read ClusterOperators'; fi
if run nodes oc get nodes -o json; then
  if js nodes '(.items|length)>0 and all(.items[]; any(.status.conditions[]?; .type=="Ready" and .status=="True"))'; then
    record PASS oc-nodes 'all discovered nodes Ready=True'
  else record FAIL oc-nodes 'node missing/Ready=False/Unknown'; fi
else record UNAVAILABLE oc-nodes 'node API inaccessible'; fi

# Discover a single intended RHOSO namespace; require explicit selection if multiple.
NS=${RHOSO_NAMESPACE:-}
if run controlplanes oc get openstackcontrolplane -A -o json; then
  if [[ -z "$NS" ]]; then
    count=$(jq -r '.items|length' "$OUTDIR/controlplanes.out")
    if [[ "$count" -eq 1 ]]; then
      NS=$(jq -r '.items[0].metadata.namespace' "$OUTDIR/controlplanes.out")
      record PASS cloud-discovery "selected sole RHOSO namespace=$NS"
    elif [[ "$count" -eq 0 ]]; then record FAIL cloud-discovery 'no OpenStackControlPlane found'
    else record UNAVAILABLE cloud-discovery 'multiple clouds; set RHOSO_NAMESPACE explicitly'; fi
  else
    if jq -e --arg ns "$NS" 'any(.items[]; .metadata.namespace==$ns)' "$OUTDIR/controlplanes.out" >/dev/null; then
      record PASS cloud-discovery "selected namespace=$NS"
    else record FAIL cloud-discovery "namespace=$NS has no OpenStackControlPlane"; NS=''; fi
  fi
else record UNAVAILABLE cloud-discovery 'cannot list RHOSO control planes'; NS=''; fi

if [[ -n "$NS" ]]; then
  if run cp-state oc get openstackcontrolplane -n "$NS" -o json; then
    if js cp-state '(.items|length)>0 and all(.items[]; any(.status.conditions[]?; .type=="Ready" and .status=="True"))'; then
      record PASS controlplane 'all OpenStackControlPlane Ready=True'
    elif js cp-state 'any(.items[]; any(.status.conditions[]?; .type=="Ready" and .status=="False"))'; then
      record FAIL controlplane 'OpenStackControlPlane Ready=False'
    else record WARN controlplane 'Ready condition absent/Unknown; inspect status'; fi
  else record UNAVAILABLE controlplane 'cannot read OpenStackControlPlane'; fi

  for kind in openstackdataplanenodeset openstackdataplanedeployment openstackansibleee; do
    if run "${kind}" oc get "$kind" -n "$NS" -o json; then
      if js "$kind" '(.items|length)>0 and all(.items[]; any(.status.conditions[]?; (.type=="Ready" or .type=="DeploymentReady") and .status=="True"))'; then
        record PASS "$kind" 'all resources have Ready/DeploymentReady=True'
      elif js "$kind" '(.items|length)>0 and any(.items[]; any(.status.conditions[]?; (.type=="Ready" or .type=="DeploymentReady") and .status=="False"))'; then
        record FAIL "$kind" 'resource Ready/DeploymentReady=False'
      elif js "$kind" '(.items|length)==0'; then
        record UNAVAILABLE "$kind" 'no resource; optional/undeployed/unknown'
      else record WARN "$kind" 'conditions absent/Unknown; inspect reported status'; fi
    else record UNAVAILABLE "$kind" 'CRD absent or RBAC denies inspection'; fi
  done

  if run namespacepods oc get pods -n "$NS" -o json; then
    if js namespacepods '(.items|length)>0 and all(.items[]; .status.phase=="Running" or .status.phase=="Succeeded")'; then
      record PASS service-pods 'no Pending/Failed/Unknown pod phase'
    else record WARN service-pods 'Pending/Failed/Unknown pod exists'; fi
    if js namespacepods '([.items[] | select(.status.phase=="Running")]|length)>0 and all(.items[] | select(.status.phase=="Running"); (.status.containerStatuses|length)>0 and all(.status.containerStatuses[]; .ready==true))'; then
      record PASS service-containers 'running pod containers ready'
    else record WARN service-containers 'one or more running containers not ready'; fi
  else record UNAVAILABLE service-pods 'pod inventory unavailable'; fi

  if run pvcs oc get pvc -n "$NS" -o json; then
    if js pvcs 'all(.items[]; .status.phase=="Bound")'; then record PASS pvc 'all discovered PVCs Bound'
    else record FAIL pvc 'one or more unbound PVCs'; fi
  else record UNAVAILABLE pvc 'PVC inspection unavailable'; fi

  # RabbitMQ: CR readiness plus live cluster_status executed in real pod when possible.
  if run rabbits oc get rabbitmq -n "$NS" -o json; then
    if js rabbits '(.items|length)>0 and all(.items[]; any(.status.conditions[]?; .type=="Ready" and .status=="True"))'; then
      record PASS rabbitmq-cr 'RabbitMQ Ready conditions True'
    elif js rabbits '(.items|length)==0'; then record UNAVAILABLE rabbitmq-cr 'no RabbitMQ CR'
    else record WARN rabbitmq-cr 'readiness not proven by CR; inspect operator status'; fi
  else record UNAVAILABLE rabbitmq-cr 'RabbitMQ CR inaccessible'; fi
  if run rabbitpods oc get pods -n "$NS" -l app.kubernetes.io/name=rabbitmq -o json; then
    rabbit_seen=0; rabbit_bad=0
    while IFS=$'\t' read -r rp rc; do
      [[ -n "$rp" && -n "$rc" ]] || continue
      rabbit_seen=$((rabbit_seen+1))
      if ! run "rabbitdiag-${rabbit_seen}" oc exec -n "$NS" "$rp" -c "$rc" -- rabbitmqctl cluster_status; then
        rabbit_bad=$((rabbit_bad+1))
      fi
    done < <(jq -r '.items[] | select(.status.phase=="Running") | [.metadata.name,.spec.containers[0].name] | @tsv' "$OUTDIR/rabbitpods.out")
    if (( rabbit_seen == 0 )); then record UNAVAILABLE rabbitmq-live 'no running labeled RabbitMQ pod'
    elif (( rabbit_bad > 0 )); then record FAIL rabbitmq-live "$rabbit_bad/$rabbit_seen selected brokers failed cluster_status; inspect rabbitdiag-*.err"
    else record PASS rabbitmq-live "all $rabbit_seen discovered running RabbitMQ pods answer cluster_status"; fi
  else record UNAVAILABLE rabbitmq-live 'RabbitMQ pod inventory unavailable'; fi

  if run galeras oc get galera -n "$NS" -o json; then
    if js galeras '(.items|length)>0 and all(.items[]; any(.status.conditions[]?; .type=="Ready" and .status=="True"))'; then
      record PASS galera-operator 'all Galera CRs Ready=True (NOT proof wsrep synced)'
    elif js galeras '(.items|length)==0'; then record UNAVAILABLE galera-operator 'no Galera CR'
    else record WARN galera-operator 'CR readiness not established'; fi
    record UNAVAILABLE galera-wsrep 'SQL wsrep checks need authorized interactive DBA credentials; never expose secrets'
  else record UNAVAILABLE galera-operator 'Galera CR unavailable'; fi

  # OVN DB inspection inside discovered RHOSO database pods.
  if [[ -s "$OUTDIR/namespacepods.out" ]]; then
    for db in nb sb; do
      pod=$(jq -r --arg db "$db" '[.items[]|select(.metadata.name|test("ovsdbserver-"+$db+"([0-9-]|$)"))|select(.status.phase=="Running")|.metadata.name][0]//empty' "$OUTDIR/namespacepods.out")
      if [[ -n "$pod" ]]; then
        cont=$(jq -r --arg p "$pod" '[.items[] | select(.metadata.name==$p)|.spec.containers[0].name][0]//empty' "$OUTDIR/namespacepods.out")
        if [[ "$db" == nb ]]; then ovn_cmd=(ovn-nbctl show); else ovn_cmd=(ovn-sbctl chassis-list); fi
        if run "ovn-$db" oc exec -n "$NS" "$pod" -c "$cont" -- "${ovn_cmd[@]}"; then
          if [[ "$db" == sb && ! -s "$OUTDIR/ovn-$db.out" ]]; then record WARN ovn-sb 'command succeeded but no chassis listed'
          else record PASS "ovn-$db" "OVN $db query succeeded against $pod"; fi
        else record UNAVAILABLE "ovn-$db" 'DB CLI/TLS/container access failed; inspect ovn-*.err'; fi
      else record UNAVAILABLE "ovn-$db" 'no running ovsdbserver pod found'; fi
    done
  else record UNAVAILABLE ovn 'pod inventory unavailable'; fi

  # Discover one running OpenStackClient in selected cloud. Do not output env, tokens, secrets.
  CLIENT=''; CC=''
  if [[ -s "$OUTDIR/namespacepods.out" ]]; then
    CLIENT=$(jq -r '[.items[]|select(.metadata.name=="openstackclient" or (.metadata.name|startswith("openstackclient-")))|select(.status.phase=="Running")|.metadata.name][0]//empty' "$OUTDIR/namespacepods.out")
    CC=$(jq -r --arg p "$CLIENT" '[.items[]|select(.metadata.name==$p)|.spec.containers[0].name][0]//empty' "$OUTDIR/namespacepods.out")
  fi
  os() { oc exec -n "$NS" "$CLIENT" -c "$CC" -- openstack "$@"; }
  if [[ -n "$CLIENT" && -n "$CC" ]]; then
    if run keystone os token issue -f value -c expires; then
      record PASS keystone-auth 'authenticated Keystone token expiry obtained; token NOT printed'
      if run endpoints os endpoint list -f json; then
        if js endpoints 'length>0'; then record PASS endpoint-catalog 'API endpoints registered (does NOT prove reachability)'
        else record FAIL endpoint-catalog 'catalog has no endpoints'; fi
      else record UNAVAILABLE endpoint-catalog 'catalog query failed'; fi
      # These are independent real API reads, not merely pod/process health.
      pass_rc nova-api nova-api os server list --limit 1 -f json || :
      pass_rc neutron-api neutron-api os network list -f json || :
      pass_rc glance-api glance-api os image list -f json || :
      pass_rc cinder-api cinder-api os volume list -f json || :

      if run computes os compute service list -f json; then
        if js computes '[.[] | select((.Binary//.binary)=="nova-compute")]|length>0'; then
          if js computes 'all(.[]|select((.Binary//.binary)=="nova-compute"); ((.State//.state|ascii_downcase)=="up") and ((.Status//.status|ascii_downcase)=="enabled"))'; then
            record PASS nova-compute 'all returned nova-compute services up/enabled'
          else record FAIL nova-compute 'one or more nova-compute services not up/enabled'; fi
        else record WARN nova-compute 'zero nova-compute services returned'; fi
      else record UNAVAILABLE nova-compute 'compute service list failed'; fi
      if run capacity os hypervisor stats show -f json; then
        if js capacity '((.vcpus | tonumber? // 0) > 0) and ((.memory_mb | tonumber? // 0) > 0)'; then
          record PASS compute-capacity 'positive aggregate vCPU/RAM inventory; does NOT prove schedulable placement'
        else record WARN compute-capacity 'aggregate capacity unavailable/zero'; fi
      else record UNAVAILABLE compute-capacity 'hypervisor stats failed'; fi
      if run agents os network agent list -f json; then
        if js agents 'length==0'; then record WARN neutron-agents 'no agents returned; inspect OVN mechanism topology'
        elif js agents 'all(.[]; ((if has("Alive") then .Alive elif has("alive") then .alive else null end) | if type=="boolean" then . else (.=="true" or .==":-)") end) and ((.State // .state // "" | tostring | ascii_downcase)=="up"))'; then
          record PASS neutron-agents 'all returned agents alive/up'
        else record WARN neutron-agents 'one or more agents down/missing Alive; inspect agents.out'; fi
      else record UNAVAILABLE neutron-agents 'network agent API unsupported/unavailable'; fi
      if run backends os volume service list -f json; then
        if js backends 'length==0'; then record WARN cinder-backends 'Cinder reports no backend services'
        elif js backends 'all(.[]; ((.State//.state|ascii_downcase)=="up") and ((.Status//.status|ascii_downcase)=="enabled"))'; then
          record PASS cinder-backends 'all returned services up/enabled'
        else record FAIL cinder-backends 'backend service down or disabled'; fi
      else record UNAVAILABLE cinder-backends 'Cinder backend query not available'; fi
    else
      record FAIL keystone-auth 'token expiry request failed, credentials or Keystone API unavailable'
      for name in endpoint-catalog nova-api neutron-api glance-api cinder-api nova-compute compute-capacity neutron-agents cinder-backends; do
        record UNAVAILABLE "$name" 'dependent on authenticated OpenStack API'
      done
    fi
  else
    record UNAVAILABLE openstackclient 'running OpenStackClient could not be discovered'
    for name in keystone-auth endpoint-catalog nova-api neutron-api glance-api cinder-api nova-compute compute-capacity neutron-agents cinder-backends; do
      record UNAVAILABLE "$name" 'no OpenStackClient execution context'
    done
  fi

  # Nova cell host mapping executes in one dynamically selected conductor container.
  if [[ -s "$OUTDIR/namespacepods.out" ]]; then
    np=$(jq -r '[.items[]|select(.metadata.name|test("^nova-.*conductor-"))|select(.status.phase=="Running")|.metadata.name][0]//empty' "$OUTDIR/namespacepods.out")
    nc=$(jq -r --arg p "$np" '[.items[]|select(.metadata.name==$p)|.spec.containers[0].name][0]//empty' "$OUTDIR/namespacepods.out")
    if [[ -n "$np" && -n "$nc" ]]; then
      if run cells oc exec -n "$NS" "$np" -c "$nc" -- nova-manage cell_v2 list_hosts; then
        if [[ -f "$OUTDIR/computes.out" ]]; then
          missing=0; mapped=0
          while IFS= read -r compute; do
            [[ -z "$compute" ]] && continue
            mapped=$((mapped+1))
            grep -Fq -- "$compute" "$OUTDIR/cells.out" || missing=$((missing+1))
          done < <(jq -r '.[] | select((.Binary//.binary)=="nova-compute") | .Host // .host // empty' "$OUTDIR/computes.out")
          if ((mapped > 0 && missing == 0)); then
            record PASS nova-cells "all $mapped Nova compute service host names found in cell host mappings"
          else record WARN nova-cells "missing mappings=$missing; mapped compute services=$mapped; verify each cell"; fi
        else record WARN nova-cells 'host mappings accessible but compute service comparison unavailable'; fi
      else record UNAVAILABLE nova-cells 'nova-manage tool/container/permissions inaccessible'; fi
    else record UNAVAILABLE nova-cells 'running conductor pod not discovered'; fi
  else record UNAVAILABLE nova-cells 'pod inventory inaccessible'; fi
fi

if run events oc get events -A -o json; then
  # Only Warning events within 30 minutes, to avoid historical-noise false alarms.
  if ! jq -e '(.items|type)=="array"' "$OUTDIR/events.out" >/dev/null 2>&1; then
    record UNAVAILABLE recent-events 'event API response cannot be parsed'
  elif jq -e '[.items[]|select(.type=="Warning")|(.eventTime // .lastTimestamp // .metadata.creationTimestamp // "")|select(length>=19)|try (sub("\\.[0-9]+Z$";"Z")|fromdateiso8601) catch 0|select(. >= (now-1800))]|length>0' "$OUTDIR/events.out" >/dev/null 2>&1; then
    record WARN recent-events 'cluster Warning events in previous 30m; inspect events.out'
  else record PASS recent-events 'no recognizable Warning events in previous 30m'; fi
else record UNAVAILABLE recent-events 'cluster event API unavailable'; fi

printf '\n# CONSOLIDATED SUMMARY\n'
for state in PASS WARN FAIL UNAVAILABLE; do
  num=$(awk -F '\t' -v s="$state" '$1==s {n++} END {print n+0}' "$SUMMARY")
  printf '%-11s %d\n' "$state" "$num"
done
printf 'REPORT_DIR=%s\n' "$OUTDIR"
# Exit 2 = definite FAIL, 1 = incomplete/warning, 0 = all checks passed.
if grep -q $'^FAIL\t' "$SUMMARY"; then exit 2; fi
if grep -Eq '^(WARN|UNAVAILABLE)[[:space:]]' "$SUMMARY"; then exit 1; fi
exit 0