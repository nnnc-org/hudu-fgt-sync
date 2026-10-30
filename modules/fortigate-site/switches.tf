resource "hudu_asset" "switch" {
  for_each        = local.switches
  company_id      = var.company_id
  asset_layout_id = var.fortiswitch_layout_id
  name            = coalesce(try(each.value.cfg.name, ""), each.key)

  primary_manufacturer = "Fortinet"
  primary_model        = try(each.value.st.model, null) # model not exposed by API; null (not "") to round-trip
  primary_serial       = try(each.value.st.serial, each.value.cfg.sn, each.key)

  custom_fields = {
    model               = try(each.value.st.model, "")
    serial              = try(each.value.st.serial, each.value.cfg.sn, each.key)
    status              = try(each.value.st.status, each.value.st.state, "")
    firmware            = try(each.value.st.os_version, "")
    fortilink_port      = lookup(local.switch_uplink, each.key, "") # switch's uplink port to the FortiGate
    warranty_expiration = null
    connected_firewall  = [tonumber(hudu_asset.firewall.id)]
    port_summary        = lookup(local.switch_port_html, each.key, "")
  }
}
