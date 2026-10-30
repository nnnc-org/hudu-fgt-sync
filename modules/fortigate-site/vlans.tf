# One VLAN zone per FortiGate/VDOM, named "<fortigate> - <vdom>". Only created when
# the FortiGate actually has tagged VLAN interfaces.
resource "hudu_vlan_zone" "zone" {
  count          = length(local.vlans) > 0 ? 1 : 0
  name           = "${var.fgt_name} - ${var.vdom}"
  company_id     = var.company_id
  vlan_id_ranges = join(",", sort([for vid in local.vlan_ids : tostring(vid)]))
}

# One Hudu VLAN per unique 802.1Q id (deduped across sub-interfaces).
resource "hudu_vlan" "v" {
  for_each     = local.vlans_by_id
  name         = each.value.ifaces[0]
  vlan_id      = each.value.vlanid
  company_id   = var.company_id
  vlan_zone_id = tonumber(hudu_vlan_zone.zone[0].id)
  description  = "${var.fgt_name} - ${var.vdom} - ${join(", ", each.value.ifaces)}"
}
