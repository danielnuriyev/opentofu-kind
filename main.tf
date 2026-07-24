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
}

resource "null_resource" "kind_cluster" {
  triggers = {
    cluster_name   = local.cluster_name
    default_config = local.default_config
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      if ! kind get clusters 2>/dev/null | grep -qx "${local.cluster_name}"; then
        kind create cluster --name "${local.cluster_name}" --wait 120s
      fi

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
