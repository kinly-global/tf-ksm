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

  # Declare environment specific variables
  # using the vars module outputs
  # ....
  # eg:
  # secrets = module.vars.merged.secrets
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
}

#####################################################
#
# Include modules needed to set up your infra
#
#####################################################




