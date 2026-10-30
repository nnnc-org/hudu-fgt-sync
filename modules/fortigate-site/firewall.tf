resource "hudu_asset" "firewall" {
  company_id      = var.company_id
  asset_layout_id = var.fortigate_layout_id
  name            = local.fw_hostname

  primary_manufacturer = "Fortinet"
  primary_model        = local.fw_model
  primary_serial       = local.fw_serial

  custom_fields = {
    hostname                     = local.fw_hostname
    model                        = local.fw_model
    serial                       = local.fw_serial
    firmware                     = local.fw_version
    management_ip                = local.fw_mgmt_ip
    ha_role                      = local.fw_ha_role
    vdom                         = var.vdom
    support_contract_expiration  = local.support_contract_expiration
    hardware_warranty_expiration = null # FortiGate API does not expose hardware warranty; fill manually in Hudu
    fortiguard_entitlements      = local.entitlements_html
    static_routes                = local.static_routes_html
  }
}
