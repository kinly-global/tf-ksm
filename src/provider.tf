provider "google" {
  project = local.gcp_project
}

provider "google-beta" {
  project = local.gcp_project
}
