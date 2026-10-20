# 20. DAILY RHOSO OPERATIONAL HEALTH CHECK

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Executable script is delivered separately as rhoso-healthcheck.sh. This section is its invocation and verification; all script infrastructure calls are read-only. The script intentionally reports unavailable checks distinctly.

# [OCP][RO] Validate script Bash syntax before execution
bash -n ./scripts/rhoso-healthcheck.sh

# [OCP][RO] Execute read-only RHOSO health check with namespace autoselection
bash ./scripts/rhoso-healthcheck.sh

# [OCP][RO] Select explicit control-plane namespace if more than one exists
RHOSO_NAMESPACE="${NS}" bash ./scripts/rhoso-healthcheck.sh

# [OCP][RO] Inspect status exit code 0/1/2 per script summary
echo "$?"
```