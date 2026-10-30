# Layout ids, passed into each fortigate-site module call so its assets and
# AssetTag links target the right layouts.

output "fortigate_id" {
  description = "Hudu asset layout id for FortiGate devices."
  value       = tonumber(hudu_asset_layout.fortigate.id)
}

output "fortiswitch_id" {
  description = "Hudu asset layout id for FortiSwitch devices."
  value       = tonumber(hudu_asset_layout.fortiswitch.id)
}

output "fortiap_id" {
  description = "Hudu asset layout id for FortiAP devices."
  value       = tonumber(hudu_asset_layout.fortiap.id)
}

output "ssid_id" {
  description = "Hudu asset layout id for SSIDs."
  value       = tonumber(hudu_asset_layout.ssid.id)
}
