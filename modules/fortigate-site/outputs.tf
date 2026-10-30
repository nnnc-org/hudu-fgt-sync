output "firewall_asset_id" {
  description = "Hudu asset id of the FortiGate."
  value       = hudu_asset.firewall.id
}

output "counts" {
  description = "Number of each object type synced from this FortiGate."
  value = {
    vlans    = length(local.vlans)
    networks = length(local.network_ifaces)
    switches = length(local.switches)
    aps      = length(local.aps)
    ssids    = length(local.ssids)
    routes   = length(local.routes)
  }
}
