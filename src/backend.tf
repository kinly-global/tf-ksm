terraform {
  backend "gcs" {
    prefix = var.project
  }
}
