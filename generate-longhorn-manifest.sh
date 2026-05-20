#!/usr/bin/env bash
set -euo pipefail

# renovate: datasource=helm depName=longhorn registryUrl=https://charts.longhorn.io
LONGHORN_VERSION=1.11.2
#WORKDIR="/opt/hauler/rancher"
WORKDIR="${WORKDIR:-${HOME}/Downloads/hauler/automate}"

# Setup Working Directory
rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Get longhorn Images
LONGHORN_IMAGES=$(curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v${LONGHORN_VERSION}/deploy/longhorn-images.txt | sed -e "s/^/    - name: /")

# Create Hauler Manifest
cat > ${WORKDIR}/longhorn-manifest.yaml << EOF
apiVersion: content.hauler.cattle.io/v1
kind: Charts
metadata:
  name: longhorn-chart
spec:
  charts:
    - name: longhorn
      repoURL: https://charts.longhorn.io
      version: ${LONGHORN_VERSION}
---
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: longhorn-images
spec:
  images:
${LONGHORN_IMAGES}
EOF