locals {
  name = "${var.name_prefix}-${var.environment}"

  labels = {
    app         = "metabase"
    environment = var.environment
    managed-by  = "terraform"
  }

  required_apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "required" {
  for_each = toset(local.required_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
