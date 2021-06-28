data "google_project" "project" {
}

data "terraform_remote_state" "network" {
  backend   = "gcs"
  workspace = format("%s-%s", var.customer, var.environment)

  config = {
    bucket = local.network_state_bucket
    prefix = "network"
  }
}

locals {
  cicd_gcp_project     = format("videocloud-cicd-%s-%s", var.customer, var.environment)
  network_state_bucket = format("videocloud-network-%s-%s-tf", var.customer, var.environment)
  project_number       = data.google_project.project.number
  project_id           = data.google_project.project.id
  project_name         = split("/", data.google_project.project.id)[1]
  network              = data.terraform_remote_state.network.outputs

  merged = {
    owner = "kinly-ops"

    # construct your merged vars based on env specific values here
    # eg:
    # instances = merge(
    #   local.default_instances,
    #   try(local.instances[var.customer]["default"], {}),
    #   try(local.instances[var.customer][var.environment][var.slice], {})
    # )
  }
}
