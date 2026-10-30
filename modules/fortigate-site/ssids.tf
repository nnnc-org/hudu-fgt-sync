resource "hudu_asset" "ssid" {
  for_each        = local.ssids
  company_id      = var.company_id
  asset_layout_id = var.ssid_layout_id
  name            = each.value.name

  custom_fields = {
    ssid               = try(each.value.ssid, each.value.name)
    security_mode      = try(each.value.security, "")
    vlan_id            = try(each.value.vlanid, null)
    broadcast          = try(each.value["broadcast-ssid"], "enable") == "enable"
    connected_firewall = [tonumber(hudu_asset.firewall.id)]
  }
}
