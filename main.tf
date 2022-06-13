terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.170.0"
    }
  }
  required_version = ">=0.13"
}

variable "name_prefix" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

resource "alicloud_eci_container_group" "interactsh-web" {

  container_group_name = "${var.name_prefix}interactsh-web"
  cpu                  = 1
  memory               = 2
  restart_policy       = "Always"
  security_group_id    = var.security_group_id
  vswitch_id           = var.vswitch_id # 交换机

  auto_create_eip = true
  eip_bandwidth   = 100

  auto_match_image_cache = true

  containers {

    image             = "projectdiscovery/interactsh-web"
    name              = "${var.name_prefix}interactsh-web"
    image_pull_policy = "IfNotPresent"

    environment_vars {
      key   = "PORT"
      value = 80
    }

    ports {
      port     = 80
      protocol = "TCP"
    }

    commands = ["yarn", "start"]
  }

}

output "interactsh-web_public_ip" {
  value = alicloud_eci_container_group.interactsh-web.internet_ip
}

output "interactsh-web_private_ip" {
  value = alicloud_eci_container_group.interactsh-web.intranet_ip
}