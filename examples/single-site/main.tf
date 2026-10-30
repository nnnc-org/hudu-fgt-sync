# Example root: one FortiGate documented into one Hudu company. Copy this
# directory into a private deployment repo, switch the module sources to a
# pinned git tag (see below), and add a provider + module block per FortiGate.
#
# A real deployment references the modules by a pinned tag, e.g.:
#   source = "git::https://github.com/nnnc-org/hudu-fgt-sync.git//modules/fortigate-site?ref=v0.1.0"
# This in-repo example uses relative paths so it runs without a checkout.

module "layouts" {
  source = "../../modules/hudu-layouts"
}

module "fgt_hq" {
  source    = "../../modules/fortigate-site"
  providers = { fortios = fortios.hq, hudu = hudu }

  fgt_name   = "hq"
  vdom       = var.fortigates["hq"].vdom
  company_id = var.fortigates["hq"].company_id

  fortigate_layout_id   = module.layouts.fortigate_id
  fortiswitch_layout_id = module.layouts.fortiswitch_id
  fortiap_layout_id     = module.layouts.fortiap_id
  ssid_layout_id        = module.layouts.ssid_id
}
