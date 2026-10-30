provider "hudu" {
  host    = var.hudu_host
  api_key = var.hudu_api_key
}

# One aliased fortios provider per FortiGate, keyed to an entry in the
# var.fortigates map. Alias names cannot contain hyphens; for a hyphenated key
# like "site-b" use the alias "site_b" and keep the original key in the lookup.
# Copy this block once per FortiGate.

provider "fortios" {
  alias    = "hq"
  hostname = replace(replace(trimsuffix(var.fortigates["hq"].hostname, "/"), "https://", ""), "http://", "")
  token    = var.fortigates["hq"].token
  vdom     = var.fortigates["hq"].vdom
  insecure = var.fortigates["hq"].insecure
}
