resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%*()-_=+[]{}"
}

resource "random_password" "encryption_key" {
  length  = 64
  special = false
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "${local.name}-db-password"
  labels    = local.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_secret_manager_secret" "encryption_key" {
  secret_id = "${local.name}-encryption-key"
  labels    = local.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "encryption_key" {
  secret      = google_secret_manager_secret.encryption_key.id
  secret_data = random_password.encryption_key.result
}

resource "google_service_account" "metabase" {
  account_id   = "${local.name}-run"
  display_name = "Metabase Cloud Run runtime (${var.environment})"

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_iam_member" "db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.metabase.email}"
}

resource "google_secret_manager_secret_iam_member" "encryption_key" {
  secret_id = google_secret_manager_secret.encryption_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.metabase.email}"
}
