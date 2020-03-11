###################### /////  NETWORK ZONE \\\\\\ ##############################
//https://www.terraform.io/docs/providers/okta/r/network_zone.html
resource "okta_network_zone" "myZone" {
  name     = "Area 51"
  type     = "IP"
  gateways = ["18.188.148.92-18.188.148.92"]
  //proxies  = ["2.2.3.4/24", "3.3.4.5-3.3.4.15"]
}
//Dynamic zone require : Geolocation for Network Zones or IP Trust for Network Zones to be enabled
// this is an EA feature, need to go through okta support (open a case)
// resource "okta_network_zone" "dynamic_network_zone_example" {
//   name              = "Dynamic zone for US and BE"
//   type              = "DYNAMIC"
//   dynamic_locations = ["US", "BE"]
// }
################################################################################
