resource "google_cloud_run_v2_service" "metabase" {
  name                = local.name
  location            = var.region
  labels              = local.labels
  deletion_protection = false

  template {
    service_account = google_service_account.metabase.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"

      network_interfaces {
        network    = google_compute_network.main.id
        subnetwork = google_compute_subnetwork.main.id
      }
    }

    containers {
      image = var.metabase_image

      ports {
        container_port = 3000
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }

        cpu_idle          = false
        startup_cpu_boost = true
      }

      env {
        name  = "MB_DB_TYPE"
        value = "postgres"
      }

      env {
        name  = "MB_DB_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }

      env {
        name  = "MB_DB_PORT"
        value = "5432"
      }

      env {
        name  = "MB_DB_DBNAME"
        value = google_sql_database.metabase.name
      }

      env {
        name  = "MB_DB_USER"
        value = google_sql_user.metabase.name
      }

      env {
        name = "MB_DB_PASS"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MB_ENCRYPTION_SECRET_KEY"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.encryption_key.secret_id
            version = "latest"
          }
        }
      }

      dynamic "env" {
        for_each = var.custom_domain != "" ? [1] : []

        content {
          name  = "MB_SITE_URL"
          value = "https://${var.custom_domain}"
        }
      }

      env {
        name  = "JAVA_TOOL_OPTIONS"
        value = var.java_opts
      }

      startup_probe {
        initial_delay_seconds = 30
        period_seconds        = 10
        failure_threshold     = 30

        http_get {
          path = "/api/health"
          port = 3000
        }
      }
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.db_password,
    google_secret_manager_secret_iam_member.encryption_key,
    google_secret_manager_secret_version.db_password,
    google_secret_manager_secret_version.encryption_key,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_public_access ? 1 : 0

  project  = google_cloud_run_v2_service.metabase.project
  location = google_cloud_run_v2_service.metabase.location
  name     = google_cloud_run_v2_service.metabase.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "invokers" {
  for_each = toset(var.invoker_members)

  project  = google_cloud_run_v2_service.metabase.project
  location = google_cloud_run_v2_service.metabase.location
  name     = google_cloud_run_v2_service.metabase.name
  role     = "roles/run.invoker"
  member   = each.value
}
