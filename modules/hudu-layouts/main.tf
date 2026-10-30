# The four asset layouts the FortiGate sync writes into. Layouts are global in
# Hudu (not per-company) and are created once per Hudu instance. Field labels
# here must match the custom_fields keys the fortigate-site module sets: the
# Hudu provider lowercases a label and turns spaces into underscores
# (e.g. "Serial Number" -> serial_number), so keep labels free of punctuation.

resource "hudu_asset_layout" "fortigate" {
  name              = "FortiGate"
  icon              = "fas fa-shield-alt"
  color             = "#c8102e"
  icon_color        = "#ffffff"
  include_passwords = true
  include_photos    = false
  include_comments  = true
  include_files     = true

  fields = [
    { label = "Hostname", field_type = "Text", position = 1, show_in_list = true },
    { label = "Model", field_type = "Text", position = 2, show_in_list = true },
    { label = "Serial", field_type = "Text", position = 3 },
    { label = "Firmware", field_type = "Text", position = 4 },
    { label = "Management IP", field_type = "Text", position = 5 },
    { label = "HA Role", field_type = "Text", position = 6 },
    { label = "VDOM", field_type = "Text", position = 7 },
    { label = "Support Contract Expiration", field_type = "Date", position = 8, expiration = true },
    { label = "Hardware Warranty Expiration", field_type = "Date", position = 9, expiration = true },
    { label = "FortiGuard Entitlements", field_type = "RichText", position = 10 },
    { label = "Static Routes", field_type = "RichText", position = 11 },
  ]
}

resource "hudu_asset_layout" "fortiswitch" {
  name              = "FortiSwitch"
  icon              = "fas fa-network-wired"
  color             = "#c8102e"
  icon_color        = "#ffffff"
  include_passwords = false
  include_comments  = true
  include_files     = true

  fields = [
    { label = "Model", field_type = "Text", position = 1, show_in_list = true },
    { label = "Serial", field_type = "Text", position = 2, show_in_list = true },
    { label = "Status", field_type = "Text", position = 3 },
    { label = "FortiLink Port", field_type = "Text", position = 4 },
    { label = "Warranty Expiration", field_type = "Date", position = 5, expiration = true },
    { label = "Connected Firewall", field_type = "AssetTag", position = 6, linkable_id = tonumber(hudu_asset_layout.fortigate.id) },
    { label = "Port Summary", field_type = "RichText", position = 7 },
    # appended at the end (not inserted) so existing field positions don't shift
    { label = "Firmware", field_type = "Text", position = 8 },
  ]
}

resource "hudu_asset_layout" "fortiap" {
  name              = "FortiAP"
  icon              = "fas fa-wifi"
  color             = "#c8102e"
  icon_color        = "#ffffff"
  include_passwords = false
  include_comments  = true
  include_files     = true

  fields = [
    { label = "Connectivity Profile", field_type = "Text", position = 1, show_in_list = true },
    { label = "Serial", field_type = "Text", position = 2, show_in_list = true },
    { label = "Status", field_type = "Text", position = 3 },
    { label = "IP Address", field_type = "Text", position = 4 },
    { label = "Firmware", field_type = "Text", position = 5 },
    { label = "Warranty Expiration", field_type = "Date", position = 6, expiration = true },
    { label = "Connected Firewall", field_type = "AssetTag", position = 7, linkable_id = tonumber(hudu_asset_layout.fortigate.id) },
  ]
}

resource "hudu_asset_layout" "ssid" {
  name              = "SSID"
  icon              = "fas fa-broadcast-tower"
  color             = "#c8102e"
  icon_color        = "#ffffff"
  include_passwords = false
  include_comments  = true
  include_files     = false

  fields = [
    { label = "SSID", field_type = "Text", position = 1, show_in_list = true },
    { label = "Security Mode", field_type = "Text", position = 2 },
    { label = "VLAN ID", field_type = "Number", position = 3 },
    { label = "Broadcast", field_type = "CheckBox", position = 4 },
    { label = "Connected Firewall", field_type = "AssetTag", position = 5, linkable_id = tonumber(hudu_asset_layout.fortigate.id) },
  ]
}
