variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID. Empty disables all DNS resources."
  type        = string
  default     = ""
}

variable "custom_domain" {
  description = "FQDN to serve Metabase on. Empty disables all DNS resources."
  type        = string
  default     = ""
}

locals {
  enable_dns = var.cloudflare_zone_id != "" && var.custom_domain != ""
}

resource "google_cloud_run_domain_mapping" "metabase" {
  count = local.enable_dns ? 1 : 0

  name     = var.custom_domain
  location = var.region

  metadata {
    namespace = var.project_id
    labels    = local.labels
  }

  spec {
    route_name       = google_cloud_run_v2_service.metabase.name
    certificate_mode = "AUTOMATIC"
  }
}

resource "cloudflare_dns_record" "metabase" {
  count = local.enable_dns ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = var.custom_domain
  type    = "CNAME"
  content = "ghs.googlehosted.com"
  proxied = false
  ttl     = 300
  comment = "Metabase on Cloud Run (${var.environment})"
}

output "custom_domain_url" {
  description = "Custom domain URL, if configured."
  value       = local.enable_dns ? "https://${var.custom_domain}" : null
}
