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

    image             = "htid/interactsh-web:latest"
    name              = "${var.name_prefix}interactsh-web"
    image_pull_policy = "IfNotPresent"

    environment_vars {
      key   = "PORT"
      value = 80
    }
    
    environment_vars  {
      key = "HOST"
      value = "0.0.0.0"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }

    commands = ["node_modules/.bin/craco","start"]
  }

}

output "public_ip" {
  value = alicloud_eci_container_group.interactsh-web.internet_ip
}

output "private_ip" {
  value = alicloud_eci_container_group.interactsh-web.intranet_ip
}