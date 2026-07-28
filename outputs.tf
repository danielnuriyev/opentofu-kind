output "kubeconfig" {
  description = "Path to the Kind cluster kubeconfig"
  value       = "${path.module}/.kubeconfig"
}

output "context" {
  description = "Kubernetes context name for the Kind cluster"
  value       = "kind-local"
}

output "node_count" {
  description = "Total Kind nodes (control-plane + workers)"
  value       = local.node_count
}

output "node_resources" {
  description = "Per-node Docker memory and CPU limits"
  value = {
    memory = local.node_memory
    cpus   = local.node_cpus
  }
}
