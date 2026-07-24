# Kind Cluster (OpenTofu)

Creates a local [Kind](https://kind.sigs.k8s.io/) cluster with context `kind-local`.

## Prerequisites

- [Homebrew](https://brew.sh/)
- [Docker](https://www.docker.com/products/docker-desktop/)
- [Kind](https://kind.sigs.k8s.io/) and kubectl: `brew install kind kubectl`
- [OpenTofu](https://opentofu.org/): `brew install opentofu`

## Usage

```bash
tofu init
tofu apply
```

This creates a Kind cluster named `local` (context `kind-local`) and writes a kubeconfig to `./.kubeconfig`.

## Verify

```bash
export KUBECONFIG=./.kubeconfig
kubectl cluster-info
kubectl get nodes
```

## Cleanup

```bash
tofu destroy
```

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Kind cluster creation |
| `outputs.tf` | Kubeconfig path and context name |
