terraform {
  required_version = ">= 1.12.5"

  backend "local" {
    path = ".terraform.tfstate"
  }

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.0"
    }
  }
}

locals {
  # Kind prefixes kubeconfig contexts with "kind-", so --name local -> context kind-local
  cluster_name   = "local"
  kubeconfig     = "${path.module}/.kubeconfig"
  default_config = "${pathexpand("~")}/.kube/config"
  node_count     = 3
  node_memory    = "4g"
  node_cpus      = "2"
}

resource "null_resource" "kind_cluster" {
  triggers = {
    cluster_name   = local.cluster_name
    default_config = local.default_config
    node_count     = local.node_count
    node_memory    = local.node_memory
    node_cpus      = local.node_cpus
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      apply_node_limits() {
        for name in $(docker ps --format '{{.Names}}' | grep "^${local.cluster_name}-" || true); do
          docker update \
            --memory="${local.node_memory}" \
            --memory-swap="${local.node_memory}" \
            --cpus="${local.node_cpus}" \
            "$name"
        done
      }

      if ! kind get clusters 2>/dev/null | grep -qx "${local.cluster_name}"; then
        cat <<EOF > /tmp/${local.cluster_name}-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${local.cluster_name}

nodes:
- role: control-plane
  image: kindest/node:v1.31.0
EOF
        for _ in $(seq 1 ${local.node_count}); do
          cat <<EOF >> /tmp/${local.cluster_name}-config.yaml
- role: worker
  image: kindest/node:v1.31.0
EOF
        done
        kind create cluster --name "${local.cluster_name}" --config /tmp/${local.cluster_name}-config.yaml --wait 120s
        rm -f /tmp/${local.cluster_name}-config.yaml
      fi

      apply_node_limits

      kind export kubeconfig --name "${local.cluster_name}" --kubeconfig "${local.kubeconfig}"

      # Merge into default kubeconfig so Docker Desktop sees kind-local
      kind export kubeconfig --name "${local.cluster_name}" --kubeconfig "${local.default_config}"
      kubectl --kubeconfig="${local.default_config}" config use-context kind-local
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      KCFG='${lookup(self.triggers, "default_config", "")}'
      [ -z "$KCFG" ] && KCFG="$HOME/.kube/config"
      kubectl --kubeconfig="$KCFG" config delete-context kind-local 2>/dev/null || true
      kubectl --kubeconfig="$KCFG" config delete-cluster kind-local 2>/dev/null || true
      kubectl --kubeconfig="$KCFG" config delete-user kind-local 2>/dev/null || true
      kind delete cluster --name ${self.triggers.cluster_name} 2>/dev/null || true
    EOT
  }
}
