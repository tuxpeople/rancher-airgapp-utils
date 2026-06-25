#!/usr/bin/env bash
set -euo pipefail

# renovate: datasource=helm depName=cert-manager registryUrl=https://charts.jetstack.io
CERTMANAGER_VERSION=v1.20.3
#WORKDIR="/opt/hauler/rancher"
WORKDIR="${WORKDIR:-${HOME}/Downloads/hauler/automate}"

# Setup Working Directory
rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Get Cert-Manager Images
helm repo add jetstack https://charts.jetstack.io && helm repo update
CERTMANAGER_IMAGES=$(helm template jetstack/cert-manager --version=${CERTMANAGER_VERSION} --include-crds | grep 'image:' | sed 's/"//g' | awk '{ print $2 }' | sed -e "s/^/    - name: /")

# Create Hauler Manifest
cat > ${WORKDIR}/cert-manager-manifest.yaml << EOF
apiVersion: content.hauler.cattle.io/v1
kind: Charts
metadata:
  name: cert-manager-chart
spec:
  charts:
    - name: cert-manager
      repoURL: https://charts.jetstack.io
      version: ${CERTMANAGER_VERSION}
---
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: cert-manager-images
spec:
  images:
${CERTMANAGER_IMAGES}
EOF