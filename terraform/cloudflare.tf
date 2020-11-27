provider "cloudflare" {
  version = "~> 2.0"
}

resource "cloudflare_zone" "rtnet" {
  zone = "rtnet.io"
}

resource "cloudflare_zone" "rooftopllc" {
  zone = "rooftopllc.net"
}

resource "cloudflare_record" "edge-vultr-gw1" {
  zone_id = cloudflare_zone.rtnet.id

  name = "edge-vultr-gw1"
  type = "AAAA"

  value = vultr_server.edge-vultr-gw1.v6_networks[0].v6_main_ip
}

resource "cloudflare_record" "rooftopllc_spf" {
  zone_id = cloudflare_zone.rooftopllc.id

  name = "@"
  type = "TXT"
  value = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "cloudflare_record" "fastmail_domainkey1" {
  zone_id = cloudflare_zone.rooftopllc.id
  name = "fm1._domainkey"
  type = "CNAME"
  value = "fm1.${cloudflare_zone.rooftopllc.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_domainkey2" {
  zone_id = cloudflare_zone.rooftopllc.id
  name = "fm2._domainkey"
  type = "CNAME"
  value = "fm2.${cloudflare_zone.rooftopllc.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_domainkey3" {
  zone_id = cloudflare_zone.rooftopllc.id
  name = "fm3._domainkey"
  type = "CNAME"
  value = "fm3.${cloudflare_zone.rooftopllc.zone}.dkim.fmhosted.com"
}

resource "cloudflare_record" "fastmail_mx10" {
  zone_id = cloudflare_zone.rooftopllc.id
  name = "@"
  type = "MX"
  priority = 10
  value = "in1-smtp.messagingengine.com"
}

resource "cloudflare_record" "fastmail_mx20" {
  zone_id = cloudflare_zone.rooftopllc.id
  name = "@"
  type = "MX"
  priority = 20
  value = "in2-smtp.messagingengine.com"
}
