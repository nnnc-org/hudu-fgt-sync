locals {
  # ---- raw decoded responses -------------------------------------------------
  status_raw  = try(jsondecode(data.fortios_json_generic_api.system_status.response), {})
  global_raw  = try(jsondecode(data.fortios_json_generic_api.system_global.response), {})
  license_raw = try(jsondecode(data.fortios_json_generic_api.license.response).results, {})
  ifaces      = try(jsondecode(data.fortios_json_generic_api.interfaces.response).results, [])
  routes      = try(jsondecode(data.fortios_json_generic_api.static_routes.response).results, [])

  switches_cfg         = try(jsondecode(data.fortios_json_generic_api.switches_cfg.response).results, [])
  switches_status_list = try(jsondecode(data.fortios_json_generic_api.switches_status.response).results, [])
  aps_cfg              = try(jsondecode(data.fortios_json_generic_api.aps_cfg.response).results, [])
  aps_status_list      = try(jsondecode(data.fortios_json_generic_api.aps_status.response).results, [])
  ssids_raw            = try(jsondecode(data.fortios_json_generic_api.ssids.response).results, [])

  # ---- device identity -------------------------------------------------------
  # On monitor endpoints serial/version sit at the envelope top level, while
  # model/hostname live under .results — hence the try() fallbacks.
  fw_serial   = try(local.status_raw.serial, local.status_raw.results.serial, "")
  fw_version  = try(local.status_raw.version, local.status_raw.results.version, "")
  fw_model    = try(local.status_raw.results.model, local.status_raw.results.model_name, "")
  fw_hostname = try(coalesce(try(local.global_raw.results.hostname, null), try(local.status_raw.results.hostname, null)), var.fgt_name)
  fw_ha_role  = try(local.status_raw.results.ha_mode, local.status_raw.results.ha, "")
  # host address (not network) of the management interface, if present
  fw_mgmt_ip = try(
    split(" ", trimspace(local.network_ifaces["mgmt"].ip))[0],
    split(" ", trimspace(local.network_ifaces["mgmt1"].ip))[0],
    ""
  )

  # ---- dotted netmask -> prefix length --------------------------------------
  netmask2cidr = {
    "255.255.255.255" = 32, "255.255.255.254" = 31, "255.255.255.252" = 30,
    "255.255.255.248" = 29, "255.255.255.240" = 28, "255.255.255.224" = 27,
    "255.255.255.192" = 26, "255.255.255.128" = 25, "255.255.255.0" = 24,
    "255.255.254.0"   = 23, "255.255.252.0" = 22, "255.255.248.0" = 21,
    "255.255.240.0"   = 20, "255.255.224.0" = 19, "255.255.192.0" = 18,
    "255.255.128.0"   = 17, "255.255.0.0" = 16, "255.254.0.0" = 15,
    "255.252.0.0"     = 14, "255.248.0.0" = 13, "255.240.0.0" = 12,
    "255.224.0.0"     = 11, "255.192.0.0" = 10, "255.128.0.0" = 9,
    "255.0.0.0"       = 8, "254.0.0.0" = 7, "252.0.0.0" = 6, "248.0.0.0" = 5,
    "240.0.0.0"       = 4, "224.0.0.0" = 3, "192.0.0.0" = 2, "128.0.0.0" = 1,
    "0.0.0.0"         = 0,
  }

  # ---- interfaces: VLANs + networks -----------------------------------------
  vlans = { for i in local.ifaces : i.name => i if try(i.type, "") == "vlan" }

  # Hudu requires a VLAN id to be unique within a zone, but a FortiGate can have
  # several VLAN sub-interfaces sharing one 802.1Q id (on different parents).
  # Collapse to one Hudu VLAN per id; the per-interface subnets remain as networks.
  vlan_ids = distinct([for i in local.vlans : i.vlanid])
  vlans_by_id = {
    for vid in local.vlan_ids : tostring(vid) => {
      vlanid = vid
      ifaces = sort([for i in local.vlans : i.name if i.vlanid == vid])
    }
  }

  # every interface that has a configured IPv4 address (vlan or not)
  network_ifaces = {
    for i in local.ifaces : i.name => i
    if try(i.ip, "0.0.0.0 0.0.0.0") != "0.0.0.0 0.0.0.0" && length(split(" ", trimspace(try(i.ip, "")))) == 2
  }
  network_cidr = {
    for name, i in local.network_ifaces :
    name => format("%s/%d",
      cidrhost(format("%s/%d", split(" ", trimspace(i.ip))[0], local.netmask2cidr[split(" ", trimspace(i.ip))[1]]), 0),
      local.netmask2cidr[split(" ", trimspace(i.ip))[1]]
    )
  }

  # ---- switches: merge cmdb config with monitor status (keyed by switch id) --
  switches_status = { for s in local.switches_status_list : try(s["switch-id"], tostring(s.serial), "") => s }
  switches = {
    for s in local.switches_cfg : try(s["switch-id"], s.name) => {
      cfg = s
      st  = lookup(local.switches_status, try(s["switch-id"], ""), {})
    }
  }

  # ---- APs: merge cmdb config with monitor status (keyed by wtp id) ----------
  aps_status = { for a in local.aps_status_list : try(tostring(a.wtp_id), tostring(a.name), "") => a }
  aps = {
    for a in local.aps_cfg : try(a["wtp-id"], a.name) => {
      cfg = a
      st  = lookup(local.aps_status, try(a["wtp-id"], ""), {})
    }
  }

  # ---- SSIDs -----------------------------------------------------------------
  ssids = { for v in local.ssids_raw : v.name => v }

  # ---- license / warranty ----------------------------------------------------
  support_expire_epoch = try(
    local.license_raw.forticare.support.expires,
    local.license_raw.forticare.support.hardware.expires,
    local.license_raw.support.expires,
    null
  )
  support_contract_expiration = local.support_expire_epoch == null ? null : formatdate("YYYY/MM/DD", timeadd("1970-01-01T00:00:00Z", format("%ds", local.support_expire_epoch)))

  # FortiGuard entitlements: any top-level license entry that carries an `expires` epoch.
  entitlement_rows = try([
    for k, v in local.license_raw : {
      name = k
      exp  = try(formatdate("YYYY/MM/DD", timeadd("1970-01-01T00:00:00Z", format("%ds", v.expires))), "")
    } if try(v.expires, null) != null
  ], [])

  # ---- RichText tables -------------------------------------------------------
  static_routes_html = length(local.routes) == 0 ? "" : join("", concat(
    ["<table><thead><tr><th>Seq</th><th>Destination</th><th>Gateway</th><th>Device</th><th>Distance</th><th>Comment</th></tr></thead><tbody>"],
    [for r in local.routes : format("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
    try(tostring(r["seq-num"]), ""), try(r.dst, ""), try(r.gateway, ""), try(r.device, ""), try(tostring(r.distance), ""), try(r.comment, ""))],
    ["</tbody></table>"],
  ))

  entitlements_html = length(local.entitlement_rows) == 0 ? "" : join("", concat(
    ["<table><thead><tr><th>Service</th><th>Expires</th></tr></thead><tbody>"],
    [for e in local.entitlement_rows : format("<tr><td>%s</td><td>%s</td></tr>", e.name, e.exp)],
    ["</tbody></table>"],
  ))

  # uplink port(s) of each switch: the FortiLink port if directly attached to the
  # FortiGate, otherwise the inter-switch-link (ISL) port(s) toward the parent switch.
  switch_uplink = {
    for id, s in local.switches : id => (
      length([for p in try(s.cfg.ports, []) : p["port-name"] if try(p["fortilink-port"], 0) != 0]) > 0
      ? [for p in try(s.cfg.ports, []) : p["port-name"] if try(p["fortilink-port"], 0) != 0][0]
      : join(", ", [for p in try(s.cfg.ports, []) : p["port-name"] if try(p["isl-peer-port-name"], "") != ""])
    )
  }

  # per-switch port summary table: port, native VLAN, allowed (trunk) VLANs
  switch_port_html = {
    for id, s in local.switches : id => (
      length(try(s.cfg.ports, [])) == 0 ? "" : join("", concat(
        ["<table><thead><tr><th>Port</th><th>Native VLAN</th><th>Allowed VLANs</th></tr></thead><tbody>"],
        [for p in try(s.cfg.ports, []) : format("<tr><td>%s</td><td>%s</td><td>%s</td></tr>",
          try(p["port-name"], ""),
          try(tostring(p.vlan), ""),
        try(p["allowed-vlans-all"], "disable") == "enable" ? "all" : join(", ", [for v in try(p["allowed-vlans"], []) : try(v["vlan-name"], "")]))],
        ["</tbody></table>"],
      ))
    )
  }
}
