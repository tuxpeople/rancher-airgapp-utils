# rancher-airgapp-utils

Generates [Hauler](https://hauler.dev) manifests for airgapped Rancher/Kubernetes installations and publishes them to the GitHub Container Registry as OCI artifacts.

## How it works

Each product has a shell script (`generate-<product>-manifest.sh`) that:
1. Fetches the required Helm charts and container images for the specified version
2. Generates a Hauler manifest YAML

When a script is pushed to `main`, the [CI workflow](.github/workflows/generate-manifest.yml) runs it automatically and publishes the resulting manifest to GHCR:

```
ghcr.io/tuxpeople/rancher-airgapp-utils/hauler/<product>-manifest.yaml:<version>
```

## Available products

| Product | Script | Version variable |
|---|---|---|
| cert-manager | `generate-cert-manager-manifest.sh` | `CERTMANAGER_VERSION` |
| Longhorn | `generate-longhorn-manifest.sh` | `LONGHORN_VERSION` |

## Usage

### Pull a manifest and sync with Hauler

```bash
hauler store sync \
  --product-registry ghcr.io/tuxpeople/rancher-airgapp-utils \
  --products cert-manager=1.19.0

hauler store sync \
  --product-registry ghcr.io/tuxpeople/rancher-airgapp-utils \
  --products longhorn=1.10.2
```

Multiple products at once:

```bash
hauler store sync \
  --product-registry ghcr.io/tuxpeople/rancher-airgapp-utils \
  --products cert-manager=1.19.0,longhorn=1.10.2
```

### Run a script locally

```bash
bash generate-cert-manager-manifest.sh
```

The manifest is written to `~/Downloads/hauler/automate/<product>-manifest.yaml` by default. Override with the `WORKDIR` environment variable:

```bash
WORKDIR=/tmp/hauler bash generate-cert-manager-manifest.sh
```

## Adding a new product

1. Create `generate-<product>-manifest.sh` following the existing scripts as a template
2. Set the version in a variable named `*_VERSION=` (e.g. `MYPRODUCT_VERSION=1.2.3`)
3. Write the manifest to `${WORKDIR}/<product>-manifest.yaml`
4. Push to `main` — the workflow picks it up automatically

## Version updates

Versions are managed automatically by [Renovate](https://docs.renovatebot.com/). Each script has an annotation comment directly above the version variable:

```bash
# renovate: datasource=helm depName=<product> registryUrl=<chart-repo-url>
PRODUCT_VERSION=1.2.3
```

When adding a new script, add this annotation with the correct datasource and Renovate will pick up version updates automatically.
