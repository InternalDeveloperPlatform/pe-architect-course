variable "kubeconfig" {
  description = "Kubeconfig used by the Humanitec Agent / terraform"
  type        = string
  default     = "/home/vscode/state/kube/config-internal.yaml"
}

variable "tls_cert_string" {
  description = "Cert as string for TLS setup"
  type        = string
  default     = ""
}

variable "tls_key_string" {
  description = "Key as string for TLS setup"
  type        = string
  default     = ""
}
