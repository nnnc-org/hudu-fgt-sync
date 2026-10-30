resource "hudu_asset" "ap" {
  for_each        = local.aps
  company_id      = var.company_id
  asset_layout_id = var.fortiap_layout_id
  name            = coalesce(try(each.value.cfg.name, ""), each.key)

  primary_manufacturer = "Fortinet"
  primary_model        = null # FortiAP hardware model isn't exposed by the API; the WTP profile lives in the Connectivity Profile field
  primary_serial       = try(each.value.st.serial, each.key)

  custom_fields = {
    connectivity_profile = try(each.value.cfg["wtp-profile"], "")
    serial               = try(each.value.st.serial, each.key)
    status               = try(each.value.st.status, each.value.st.connection_state, "")
    ip_address           = try(each.value.st.local_ipv4_addr, each.value.st.ipaddr, "")
    firmware             = try(each.value.st.os_version, "")
    warranty_expiration  = null
    connected_firewall   = [tonumber(hudu_asset.firewall.id)]
  }
}
