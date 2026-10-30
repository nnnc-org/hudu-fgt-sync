# All reads go through the fortios provider's generic GET data source. Each returns
# the raw FortiOS API JSON in `.response`, decoded in locals.tf.

data "fortios_json_generic_api" "system_status" {
  path      = "/api/v2/monitor/system/status"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "system_global" {
  path      = "/api/v2/cmdb/system/global"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "license" {
  path      = "/api/v2/monitor/license/status"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "interfaces" {
  path      = "/api/v2/cmdb/system/interface"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "static_routes" {
  path      = "/api/v2/cmdb/router/static"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "switches_cfg" {
  path      = "/api/v2/cmdb/switch-controller/managed-switch"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "switches_status" {
  path      = "/api/v2/monitor/switch-controller/managed-switch/status"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "aps_cfg" {
  path      = "/api/v2/cmdb/wireless-controller/wtp"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "aps_status" {
  path      = "/api/v2/monitor/wifi/managed_ap"
  vdomparam = var.vdom
}

data "fortios_json_generic_api" "ssids" {
  path      = "/api/v2/cmdb/wireless-controller/vap"
  vdomparam = var.vdom
}
