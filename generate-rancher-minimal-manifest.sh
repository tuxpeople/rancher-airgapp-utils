#!/usr/bin/env bash
set -euo pipefail

# renovate: datasource=helm depName=rancher registryUrl=https://releases.rancher.com/server-charts/latest
RANCHER_VERSION=2.14.1
#WORKDIR="/opt/hauler/rancher"
WORKDIR="${WORKDIR:-${HOME}/Downloads/hauler/automate}"
IMAGEFILTER='neuvector|gke|aks|eks|sriov|harvester|tekton|istio|multus|hyper|jenkins|windows'


# Setup Working Directory
rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Get rancher Images
RANCHER_IMAGES=$(curl -sSfL "https://prime.ribs.rancher.io/rancher/v${RANCHER_VERSION}/rancher-images.txt" \
        | grep -Ev "${IMAGEFILTER}" \
        | sort -t: -k1,1 -k2,2Vr \
        | awk -F: '!seen[$1]++' \
        | sort \
        | sed -e "s/^/    - name: /")

# Create Hauler Manifest
cat > ${WORKDIR}/rancher-minimal-manifest.yaml << EOF
apiVersion: content.hauler.cattle.io/v1
kind: Charts
metadata:
  name: rancher-chart
spec:
  charts:
    - name: rancher
      repoURL: https://releases.rancher.com/server-charts/latest
      version: ${RANCHER_VERSION}
---
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: rancher-images
spec:
  images:
${RANCHER_IMAGES}
EOF