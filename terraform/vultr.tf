provider "vultr" {}

resource "vultr_ssh_key" "sshkey" {
  count = length(var.ssh_keys)

  name = var.ssh_keys[count.index].name
  ssh_key = var.ssh_keys[count.index].key
}

data "vultr_os" "openbsd" {
  filter {
    name   = "name"
    values = ["OpenBSD 6.8 x64"]
  }
}

data "vultr_region" "scv" {
  filter {
    name   = "name"
    values = ["Silicon Valley"]
  }
}

data "vultr_plan" "small" {
  filter {
    name   = "name"
    values = ["2048 MB RAM,55 GB SSD,2.00 TB BW"]
  }
}

data "vultr_plan" "large" {
  filter {
    name = "name"
    values = ["4096 MB RAM,80 GB SSD,3.00 TB BW"]
  }
}

resource "vultr_server" "edge-vultr-gw1" {
  plan_id = data.vultr_plan.small.id
  region_id = data.vultr_region.scv.id
  os_id = data.vultr_os.openbsd.id

  hostname = "edge-vultr-gw1.rtnet.io" 
  enable_ipv6 = true

  label = "edge-vultr-gw1.rtnet.io"

  ssh_key_ids = vultr_ssh_key.sshkey[*].id
}
