terraform {
  required_providers {
    fortios = {
      source = "fortinetdev/fortios"
    }
    hudu = {
      source = "nnnc-org/hudu"
    }
  }
}

variable "fgt_name" {
  type        = string
  description = "Short name for this FortiGate; used in asset, VLAN zone, and network names."
}

variable "vdom" {
  type        = string
  description = "Target VDOM. Used for naming and as vdomparam on reads."
  default     = "root"
}

variable "company_id" {
  type        = number
  description = "Hudu company id to create objects under."
}

variable "fortigate_layout_id" {
  type = number
}

variable "fortiswitch_layout_id" {
  type = number
}

variable "fortiap_layout_id" {
  type = number
}

variable "ssid_layout_id" {
  type = number
}
