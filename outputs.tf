output "kubeconfig" {
  description = "Path to the Kind cluster kubeconfig"
  value       = "${path.module}/.kubeconfig"
}

output "context" {
  description = "Kubernetes context name for the Kind cluster"
  value       = "kind-local"
}
