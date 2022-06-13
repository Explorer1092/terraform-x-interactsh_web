
```

terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.170.0"
    }
  }
}

variable "aliyun_access_key" {
  type      = string
}

variable "aliyun_secret_key" {
  type      = string
}

variable "region" {
	default = "cn-beijing"
}

provider "alicloud" {
  region     = var.region
  access_key = var.aliyun_access_key
  secret_key = var.aliyun_secret_key
}

resource "alicloud_vswitch" "interactsh" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.cidr_block, 12, 1)
  zone_id    = "cn-beijing-a"
  vswitch_name = "${local.name_prefix}-interactsh-web"
}

module "sg-interactsh_web" {
  source  = "alibaba/security-group/alicloud"

  name = "${local.name_prefix}-interactsh_web"
  description = "http服务"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp"]
}

module "interactsh_web" {
  source  = "Explorer1092/interactsh_web/x"
  version = "1.0.0"
  name_prefix = local.name_prefix
  vswitch_id = alicloud_vswitch.interactsh.id
  security_group_id = module.sg-interactsh_web.this_security_group_id
}


```