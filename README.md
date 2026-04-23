# projet_automatisation

# 🚀 NovaSphere Infrastructure

## 📌 Description

Ce projet met en place une **infrastructure cloud complète, sécurisée et automatisée sur AWS** à l’aide de **Terraform** et **Ansible**.

L’objectif est de pouvoir :

* déployer toute l’infrastructure en une seule commande
* configurer automatiquement les serveurs
* détruire proprement l’environnement

---

## 🏗️ Architecture

L’infrastructure suit une architecture **multi-tier** :

* **VPC** : 10.0.0.0/16
* **Subnet public** :

  * Bastion (SSH)
  * Serveur Web (Nginx)
* **Subnet privé** :

  * Service interne (port 8080)

### 🔐 Sécurité

* Bastion = seul point d’entrée SSH
* Web :

  * HTTP (80) depuis Internet
  * SSH uniquement via bastion
* Service privé :

  * accessible uniquement depuis le web

---

## ⚙️ Technologies utilisées

* **AWS (EC2, VPC, NAT Gateway)**
* **Terraform** (Infrastructure as Code)
* **Ansible** (Configuration management)
* **Ansible Vault** (gestion des secrets)
* **SSH ProxyJump** (sécurité des accès)

---

## 📂 Structure du projet

```
novasphere-infra/
├── deploy.sh
├── destroy.sh
├── terraform/
│   └── multi-tier/
├── ansible/
│   ├── playbook.yml
│   └── roles/webserver/
```

---

## 🔐 Gestion des secrets

Les données sensibles sont stockées dans :

```
ansible/vault/secrets.yml
```

Ce fichier est chiffré avec **Ansible Vault**.

---

## 🚀 Déploiement

### 1. Cloner le projet

```bash
git clone <repo_url>
cd projet_automatisation
```

### 2. Configurer AWS

```bash
aws configure
```

### 3. Lancer le déploiement

```bash
./deploy.sh
```

---

## 🌐 Accès

Une fois déployé :

* Serveur web :

```
http://<IP_PUBLIQUE>
```

---

## 🧪 Tests

Connexion au bastion :

```bash
ssh -i ~/.ssh/novaphere ubuntu@<BASTION_IP>
```

Connexion au serveur web via bastion :

```bash
ssh -i ~/.ssh/novaphere -J ubuntu@<BASTION_IP> ubuntu@<WEB_PRIVATE_IP>
```

---

## 🧹 Destruction

Pour supprimer toute l’infrastructure :

```bash
./destroy.sh
```

---

## 🎯 Fonctionnalités

* Infrastructure AWS automatisée
* Architecture multi-tier sécurisée
* Accès SSH via bastion
* Déploiement automatique de Nginx
* Gestion des secrets avec Vault
* Déploiement et destruction en une commande

---

## 🧠 Compétences démontrées

* Cloud AWS
* Réseau (VPC, subnets, routage)
* Sécurité (Security Groups, bastion)
* Terraform (IaC)
* Ansible (automatisation)
* Gestion des secrets

---

## 📌 Auteur
MASAD FAHED
Projet réalisé dans le cadre d’un apprentissage DevOps.
