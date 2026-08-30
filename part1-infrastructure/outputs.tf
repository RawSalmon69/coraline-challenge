output "metabase_url" {
  description = "Cloud Run HTTPS URL."
  value       = google_cloud_run_v2_service.metabase.uri
}

output "cloud_sql_instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.main.name
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP. Routable only inside the VPC."
  value       = google_sql_database_instance.main.private_ip_address
}

output "cloud_sql_public_ip" {
  description = "Always empty. The instance has no public IP."
  value       = google_sql_database_instance.main.public_ip_address
}

output "db_password_secret" {
  description = "Secret Manager secret holding the database password."
  value       = google_secret_manager_secret.db_password.secret_id
}

output "encryption_key_secret" {
  description = "Secret Manager secret holding MB_ENCRYPTION_SECRET_KEY."
  value       = google_secret_manager_secret.encryption_key.secret_id
}

output "runtime_service_account" {
  description = "Service account the Cloud Run revision runs as."
  value       = google_service_account.metabase.email
}

output "vpc_network" {
  description = "VPC name."
  value       = google_compute_network.main.name
}
