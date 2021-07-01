data "google_project" "project" {
}

#data "terraform_remote_state" "network" {
#  backend   = "gcs"
#  workspace = format("%s-%s", var.customer, var.environment)
#
#  config = {
#    bucket = local.network_state_bucket
#    prefix = "network"
#  }
#}

locals {
  cicd_gcp_project = format("ssono-cicd-%s-%s", var.customer, var.environment)
  #  network_state_bucket = format("ssono-network-%s-%s-tf", var.customer, var.environment)
  project_number = data.google_project.project.number
  project_id     = data.google_project.project.id
  project_name   = split("/", data.google_project.project.id)[1]
  #  network              = data.terraform_remote_state.network.outputs

  merged = {
    owner = "kinly-devops"
    vpc   = merge(local.vpc_defaults, try(local.vpc[var.environment], {}))
#    dns_private_visibility_config = merge(
#      try(local.dns_private_visibility_config[var.customer]["all"], {}),
#      try(local.dns_private_visibility_config[var.customer][var.environment], {})
#    )
    firewalls = merge(
      local.firewall_defaults,
      try(local.firewall["all"]["all"], {}),
      try(local.firewall["all"][var.environment], {}),
      try(local.firewall[var.customer]["all"], {}),
      try(local.firewall[var.customer][var.environment], {})
    )
    # construct your merged vars based on env specific values here
    # eg:
    # instances = merge(
    #   local.default_instances,
    #   try(local.instances[var.customer]["default"], {}),
    #   try(local.instances[var.customer][var.environment][var.slice], {})
    # )
  }
}
