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

This creates a Kind cluster named `local` (context `kind-local`) with **4 nodes** (1 control-plane + 3 workers). Each node is limited to **4 GiB memory** and **2 CPUs** via Docker. A kubeconfig is written to `./.kubeconfig`.

To apply node-count changes, recreate the cluster:

```bash
tofu apply -replace=null_resource.kind_cluster
```

## Local port-forward map

When accessing services from your machine, use these localhost ports to avoid collisions between stacks:

| Service | Namespace | Port-forward | URL / address |
|---------|-----------|--------------|---------------|
| MongoDB | `mongodb` | `27017:27017` | `mongodb://localhost:27017` |
| Mongo Express | `mongodb` | `8080:8081` | `http://localhost:8080` |
| Debezium Connect | `debezium` | `8081:8083` | `http://localhost:8081` |
| Kafka | `kafka` | `8082:9094` | `localhost:8082` |
| Pulsar | `pulsar` | `8083:8080` | `http://localhost:8083` |
| Flink | `flink` | `8084:8081` | `http://localhost:8084` |
| Trino | `trino` | `8085:8080` | `http://localhost:8085` |
| MinIO API | `minio` | `9000:9000` | `http://localhost:9000` |
| MinIO console | `minio` | `9001:9001` | `http://localhost:9001` |
| Grafana | `monitoring` | `3000:80` | `http://localhost:3000` |
| Prometheus | `monitoring` | `9090:9090` | `http://localhost:9090` |

OpenTofu apply-time health checks use the same localhost ports as above.

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
