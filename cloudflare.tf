provider "cloudflare" {
  version = "~> 2.0"
}

resource "cloudflare_zone" "rtnet" {
  zone = "rtnet.io"
}

resource "cloudflare_record" "edge-vultr-gw1" {
  zone_id = cloudflare_zone.rtnet.id

  name = "edge-vultr-gw1"
  type = "AAAA"

  value = vultr_server.edge-vultr-gw1.v6_networks[0].v6_main_ip
}
