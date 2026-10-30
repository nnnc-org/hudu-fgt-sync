# hudu-fgt-sync

Reusable Terraform modules that read inventory from FortiGate firewalls and
document it in [Hudu](https://www.hudu.com/) as structured assets, networks,
VLANs, and VLAN zones. It is a one-way mirror: Terraform is authoritative, so
anything removed from a FortiGate is removed from Hudu on the next `apply`.

This repo is the **module source**. Each Hudu instance you sync into gets its
own small **deployment repo** that calls these modules, holds that instance's
credentials, and keeps its own Terraform state. See
[`examples/single-site`](examples/single-site) for a complete runnable root.

## Modules

| Module | Purpose |
|---|---|
| [`modules/hudu-layouts`](modules/hudu-layouts) | Creates the four shared asset layouts (FortiGate, FortiSwitch, FortiAP, SSID) once per Hudu instance and outputs their ids. |
| [`modules/fortigate-site`](modules/fortigate-site) | Reads one FortiGate and writes its assets, VLANs, VLAN zone, and networks into one Hudu company. Called once per FortiGate. |

Two providers, no external scripts:

- **`fortinetdev/fortios`** (one aliased provider per FortiGate) reads
  everything through its `fortios_json_generic_api` data source.
- **`nnnc-org/hudu`** writes the Hudu objects.

### What gets created in Hudu

| FortiGate source | Hudu object |
|---|---|
| The firewall (`system/status`, `system/global`, `license/status`, `router/static`) | A **FortiGate** asset: identity, firmware, license/warranty expiration dates, and a static-routes table |
| Managed switches (`switch-controller/managed-switch` + status) | **FortiSwitch** assets, linked to the firewall |
| Managed APs (`wireless-controller/wtp` + `wifi/managed_ap`) | **FortiAP** assets, linked to the firewall |
| SSIDs (`wireless-controller/vap`) | **SSID** assets, linked to the firewall |
| VLAN interfaces (`system/interface`, `type == vlan`) | **VLANs** in one **VLAN Zone** named `"<fortigate> - <vdom>"` |
| Every interface with an IP | **Networks** (`"<fortigate> - <vdom> - <interface>"`), VLAN ones linked to their VLAN |

Out of scope for now: IPsec tunnels, AP→SSID links, asset-layout grouping.

## Consuming the modules

A deployment root looks like `examples/single-site`:

```hcl
module "layouts" {
  source = "git::https://github.com/nnnc-org/hudu-fgt-sync.git//modules/hudu-layouts?ref=v0.1.0"
}

module "fgt_hq" {
  source    = "git::https://github.com/nnnc-org/hudu-fgt-sync.git//modules/fortigate-site?ref=v0.1.0"
  providers = { fortios = fortios.hq, hudu = hudu }

  fgt_name   = "hq"
  vdom       = var.fortigates["hq"].vdom
  company_id = var.fortigates["hq"].company_id

  fortigate_layout_id   = module.layouts.fortigate_id
  fortiswitch_layout_id = module.layouts.fortiswitch_id
  fortiap_layout_id     = module.layouts.fortiap_id
  ssid_layout_id        = module.layouts.ssid_id
}
```

Always pin `?ref=` to a tag. Bump the tag and run `terraform init -upgrade` to
move a deployment to a newer module version — one deployment at a time.

### Why one provider + module block per FortiGate

Terraform cannot `for_each` over provider configurations, and a module needs an
explicitly-named provider alias passed in. So each FortiGate requires its own
`provider "fortios"` block (with a unique `alias`) and its own `module` block
wiring that alias in. This repetition is unavoidable; keep both keyed by the
same short name. Call `module "layouts"` exactly **once** per deployment — all
FortiGates in the same Hudu instance share the layouts.

## Prerequisites

1. **Terraform** ≥ 1.5 (or OpenTofu).
2. A **read-only FortiGate REST API admin** on each FortiGate, and its API token
   (*System → Administrators → Create New → REST API Admin*; read-only profile;
   restrict the trusted-host CIDR to wherever Terraform runs).
3. A **Hudu API key** (*Admin → API*) and the **company id** each FortiGate
   documents into (the number in the company's Hudu URL). `scripts/list-companies.sh`
   lists company ids.

## Caveats / things to confirm against your devices

FortiOS JSON shapes vary by model and version, so some mappings are best-effort
and guarded with `try()` (they degrade to empty rather than failing):

- **License/warranty** (`/api/v2/monitor/license/status`) field layout differs
  across versions; paths in `modules/fortigate-site/locals.tf` may need adjusting.
  Hardware warranty is not exposed by the API and is left for manual entry.
- **Switch/AP status** is merged from the monitor endpoints by device id; if
  serial/model/clients come back empty, the merge key needs adjusting.
- **VLAN ids**: Hudu may restrict the accepted range; VLANs outside it are rejected.

## Releasing

Tag the repo (`git tag v0.1.0 && git push --tags`) so deployment repos can pin a
`?ref=`. Treat module changes as versioned: roll them out to one deployment,
verify, then bump the others.

## License

MIT — see [LICENSE](LICENSE).
