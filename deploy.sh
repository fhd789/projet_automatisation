#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${PROJECT_ROOT}/terraform/multi-tier"
ANSIBLE_DIR="${PROJECT_ROOT}/ansible"
VAULT_PASS_FILE="${HOME}/.vault_pass"

echo "==> Vérification des outils"
command -v terraform >/dev/null 2>&1 || { echo "Terraform non installé"; exit 1; }
command -v ansible-playbook >/dev/null 2>&1 || { echo "Ansible non installé"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "AWS CLI non installé"; exit 1; }
command -v ssh >/dev/null 2>&1 || { echo "SSH non installé"; exit 1; }

echo "==> Vérification AWS"
aws sts get-caller-identity >/dev/null

echo "==> Vérification du mot de passe Vault"
if [ ! -f "${VAULT_PASS_FILE}" ]; then
  echo "Fichier ${VAULT_PASS_FILE} introuvable"
  exit 1
fi

echo "==> Terraform init"
cd "${TF_DIR}"
terraform init

echo "==> Terraform apply"
terraform apply -auto-approve

echo "==> Récupération des IPs"
BASTION_IP="$(terraform output -raw bastion_public_ip)"
WEB_PUBLIC_IP="$(terraform output -raw web_public_ip)"
WEB_PRIVATE_IP="$(terraform state show aws_instance.web | awk -F' = ' '/private_ip/ {gsub(/"/,"",$2); print $2; exit}')"

if [ -z "${WEB_PRIVATE_IP}" ]; then
  echo "Impossible de récupérer l'IP privée du serveur web"
  exit 1
fi

echo "==> Génération de l'inventaire Ansible"
cat > "${ANSIBLE_DIR}/inventory/hosts_generated.yml" <<EOF
---
all:
  children:
    webservers:
      hosts:
        novasphere-web:
          ansible_host: ${WEB_PRIVATE_IP}
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /home/fhd/.ssh/novaphere
          ansible_ssh_common_args: '-o ProxyJump=ubuntu@${BASTION_IP}'
EOF

echo "==> Attente du boot SSH"
sleep 20

echo "==> Test SSH via bastion"
ssh -o StrictHostKeyChecking=no -i /home/fhd/.ssh/novaphere -J "ubuntu@${BASTION_IP}" "ubuntu@${WEB_PRIVATE_IP}" "echo SSH OK" >/dev/null

echo "==> Exécution Ansible"
cd "${ANSIBLE_DIR}"
ansible-playbook playbook.yml --vault-password-file "${VAULT_PASS_FILE}"

echo
echo "Déploiement terminé"
echo "Bastion : ${BASTION_IP}"
echo "Web public : http://${WEB_PUBLIC_IP}"
echo "Web privé : ${WEB_PRIVATE_IP}"
