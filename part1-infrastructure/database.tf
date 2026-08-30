resource "random_id" "db_suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "main" {
  name                = "${local.name}-pg-${random_id.db_suffix.hex}"
  database_version    = var.postgres_version
  region              = var.region
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_size         = var.db_disk_size_gb
    user_labels       = local.labels

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled = true
    }
  }

  depends_on = [google_service_networking_connection.psa]
}

resource "google_sql_database" "metabase" {
  name     = "metabase"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "metabase" {
  name     = "metabase"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}
