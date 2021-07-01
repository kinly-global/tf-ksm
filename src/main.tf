locals {
  project   = var.project
  workspace = terraform.workspace

  # Split workspace in <customer>-<env>
  workspace_split = split("-", terraform.workspace)
  customer        = local.workspace_split[0]
  environment     = local.workspace_split[1]
  slice           = local.workspace_split[2]

  gcp_project = format("%s-%s-%s-%s", var.project_prefix, local.project, local.customer, local.environment)

  region_map = {
    euw2 = "europe-west2"
    euw4 = "europe-west4"
  }

  managed_zone          = format("%s-%s-internal-kinlycloud-net-private", local.customer, local.environment)
  managed_zone_dns_name = format("%s-%s.internal.kinlycloud.net.", local.customer, local.environment)

  owner                         = module.vars.merged.owner
  vpc                           = module.vars.merged.vpc
  firewalls                     = module.vars.merged.firewalls
#  dns_private_visibility_config = module.vars.merged.dns_private_visibility_config

}

#################################################
#
# Load environment specific vars
#
################################################
module "vars" {
  source = "./modules/vars"

  customer    = local.customer
  environment = local.environment
  slice       = local.slice
  gcp_project = local.gcp_project
  project     = local.project
}

#####################################################
#
# Include modules needed to set up your infra
#
#####################################################



module "vpc" {
  source  = "binxio/network-vpc/google"
  version = "~> 1.1.1"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  network_name = local.vpc.name
  subnets      = local.vpc.subnets
  routes       = local.vpc.routes
  #  vpc_peers = {
  #    "default-vpc" = {
  #      peer_project = local.gcp_project
  #      peer_network = "default"
  #    }
  #    "shared-vpc" = {
  #      peer_project = format("%s-%s-%s-%s", var.project_prefix, "network", local.customer, local.environment)
  #      peer_network = "shared"
  #    }
  #  }
}

module "firewall" {
  source  = "binxio/network-firewall/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  firewalls = local.firewalls
  firewall_defaults = merge(module.firewall.firewall_defaults, {
    network   = module.vpc.vpc_id
    direction = "INGRESS"
  })
}

#module "dns" {
#  source      = "git::https://github.com/binxio/terraform-google-dns.git"
#  environment = local.environment
#  project     = local.project
#
#  owner = local.owner
#  dns_zones = {
#    (local.managed_zone_dns_name) = {
#      visibility = "private"
#      private_visibility_config = {
#        networks = merge(
#          {
#            "logging-proxy-vpc" = module.vpc.vpc
#            "default-vpc"       = format("projects/%s/global/networks/default", local.gcp_project)
#          },
#          try(local.dns_private_visibility_config.networks, {})
#        )
#      }
#      peering_config = {
#        target_network = {
#          network_url = format("https://www.googleapis.com/compute/v1/projects/videocloud-network-%s-%s/global/networks/shared", local.customer, local.environment)
#        }
#      }
#    }
#  }
#}
                     