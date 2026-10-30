terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hudu = {
      source  = "nnnc-org/hudu"
      version = ">= 0.1.0"
    }
    fortios = {
      source  = "fortinetdev/fortios"
      version = ">= 1.19.0"
    }
  }
}
