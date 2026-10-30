variable "hudu_host" {
  type        = string
  description = "Hudu base URL, e.g. https://hudu.example.com. Leave null to use the HUDU_API_HOST env var."
  default     = null
}

variable "hudu_api_key" {
  type        = string
  description = "Hudu API key. Leave null to use the HUDU_API_KEY env var."
  sensitive   = true
  default     = null
}

variable "fortigates" {
  description = <<-EOT
    Map of FortiGate name => connection details and the Hudu company to document it under.
    The map key is used in asset/zone names and must match a `provider "fortios"` alias
    and a `module` block (see providers.tf and main.tf).
  EOT
  type = map(object({
    hostname   = string # FortiGate URL or IP, e.g. https://fw-hq.example.com
    token      = string # REST API token for a read-only admin
    company_id = number # Hudu company id this FortiGate documents into
    vdom       = optional(string, "root")
    insecure   = optional(bool, false) # true to skip TLS verification (self-signed certs)
  }))
}
