terraform {
  backend "remote" {
    organization = "rooftop"

    workspaces {
      name = "provisioning"
    }
  }
}
