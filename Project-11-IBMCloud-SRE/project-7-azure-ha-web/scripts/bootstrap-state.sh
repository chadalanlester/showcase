# ======================================================================
# FILE: scripts/bootstrap-state.sh
# USAGE (Mac): ./scripts/bootstrap-state.sh <uniq> <location>
# Example: ./scripts/bootstrap-state.sh p7state eastus
# ======================================================================
#!/usr/bin/env bash
set -euo pipefail
UNIQ="${1:?uniq suffix required}"
LOC="${2:?location required}"
RG="tfstate-${UNIQ}-rg"
ST="tf${UNIQ}$(openssl rand -hex 3 | tr -d '\n')"
CON="tfstate"

az group create -n "$RG" -l "$LOC" >/dev/null
az storage account create -n "$ST" -g "$RG" -l "$LOC" --sku Standard_LRS --kind StorageV2 >/dev/null
az storage container create --name "$CON" --account-name "$ST" >/dev/null

cat > terraform/backend.hcl <<EOF
resource_group_name  = "${RG}"
storage_account_name = "${ST}"
container_name       = "${CON}"
key                  = "project7/terraform.tfstate"
EOF

echo "State RG: $RG"
echo "Storage : $ST"
echo "Container: $CON"
echo "Wrote terraform/backend.hcl"
