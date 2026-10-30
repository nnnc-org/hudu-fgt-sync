# Every interface with a configured IPv4 address becomes a network. VLAN-tagged
# interfaces additionally link to their hudu_vlan; non-VLAN interfaces get vlan_id = null.
resource "hudu_network" "iface" {
  for_each    = local.network_ifaces
  name        = trimspace(coalesce(try(each.value.alias, ""), each.value.name))
  address     = local.network_cidr[each.key]
  company_id  = var.company_id
  description = "${var.fgt_name} - ${var.vdom} - ${each.value.name}"
  vlan_id     = try(each.value.type, "") == "vlan" ? tonumber(hudu_vlan.v[tostring(each.value.vlanid)].id) : null
}
