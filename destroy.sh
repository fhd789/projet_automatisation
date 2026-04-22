#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${PROJECT_ROOT}/terraform/multi-tier"
ANSIBLE_INV="${PROJECT_ROOT}/ansible/inventory/hosts_generated.yml"

echo "==> Terraform destroy"
cd "${TF_DIR}"
terraform destroy -auto-approve

echo "==> Nettoyage inventaire généré"
rm -f "${ANSIBLE_INV}"

echo "Destruction terminée"
