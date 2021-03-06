variable "cloudflare_email" {
  type = string
  description = "CloudFlare Email address"
  default = "andrew@forgue.io"
}

variable "cloudflare_api_key" {
  type = string
  description = "CloudFlare API Key"
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

resource "cloudflare_zone" "rooftop" {
  zone = "rooftop.net"
}

resource "cloudflare_record" "ussea1_rooftop_net_ns1" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1"
  type = "NS"
  value = "ns1.rooftop.net"
}

resource "cloudflare_record" "ussea1_rooftop_net_ns2" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1"
  type = "NS"
  value = "ns2.rooftop.net"
}

resource "cloudflare_record" "ns1" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ns1"
  type = "AAAA"
  value = "2602:fc5a:f00::aaaa"
}
resource "cloudflare_record" "ns2" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ns2"
  type = "AAAA"
  value = "2602:fc5a:f01::aaaa"
}

resource "cloudflare_record" "ussea1_edge_hypex_v6" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1-edge-hypex"
  type = "AAAA"
  value = "2602:fcdf:4::2"
}

resource "cloudflare_record" "ussea1_edge_hypex_v4" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1-edge-hypex"
  type = "A"
  value = "134.195.12.212"
}

resource "cloudflare_record" "ussea1_oob_gw" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1-oob-gw"
  type = "AAAA"
  value = "2602:fc5a:0:100::"
}

resource "cloudflare_record" "ussea1_compute_gw" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1-compute-gw"
  type = "AAAA"
  value = "2602:fc5a:0:200::"
}

resource "cloudflare_record" "orion-oob" {
  zone_id = cloudflare_zone.rooftop.id
  name = "orion-oob"
  type = "AAAA"
  value = "2602:fc5a:0:100:ae1f:6bff:fe14:1348"
}

resource "cloudflare_record" "polar" {
  zone_id = cloudflare_zone.rooftop.id
  name = "polar"
  type = "AAAA"
  value = "2602:fc5a:0:300::1"
}

resource "cloudflare_record" "polar-oob" {
  zone_id = cloudflare_zone.rooftop.id
  name = "polar-oob"
  type = "AAAA"
  value = "2602:fc5a:0:100:ae1f:6bff:fe11:dcb2"
}

#resource "cloudflare_record" "iceberg-oob" {
#  zone_id = cloudflare_zone.rooftop.id
#  name = "iceberg-oob"
#  type = "AAAA"
#  value = ""
#}

resource "cloudflare_record" "ussea1_infra_gw" {
  zone_id = cloudflare_zone.rooftop.id
  name = "ussea1-infra-gw"
  type = "AAAA"
  value = "2602:fc5a:0:300::"
}

resource "cloudflare_record" "rooftop_spf" {
  zone_id = cloudflare_zone.rooftop.id

  name = "@"
  type = "TXT"
  value = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "cloudflare_record" "fastmail_domainkey1" {
  zone_id = cloudflare_zone.rooftop.id
  name = "fm1._domainkey"
  type = "CNAME"
  value = "fm1.${cloudflare_zone.rooftop.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_domainkey2" {
  zone_id = cloudflare_zone.rooftop.id
  name = "fm2._domainkey"
  type = "CNAME"
  value = "fm2.${cloudflare_zone.rooftop.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_domainkey3" {
  zone_id = cloudflare_zone.rooftop.id
  name = "fm3._domainkey"
  type = "CNAME"
  value = "fm3.${cloudflare_zone.rooftop.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_mx10" {
  zone_id = cloudflare_zone.rooftop.id
  name = "@"
  type = "MX"
  priority = 10
  value = "in1-smtp.messagingengine.com"
}

resource "cloudflare_record" "fastmail_mx20" {
  zone_id = cloudflare_zone.rooftop.id
  name = "@"
  type = "MX"
  priority = 20
  value = "in2-smtp.messagingengine.com"
}
