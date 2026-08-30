variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "asia-southeast1"
}

variable "environment" {
  description = "Environment name, used as a resource name suffix."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "name_prefix" {
  description = "Prefix for all resource names."
  type        = string
  default     = "metabase"
}

variable "subnet_cidr" {
  description = "Subnet CIDR used by Cloud Run direct VPC egress."
  type        = string
  default     = "10.20.0.0/24"
}

variable "postgres_version" {
  description = "Cloud SQL PostgreSQL version."
  type        = string
  default     = "POSTGRES_16"
}

variable "db_tier" {
  description = "Cloud SQL machine type."
  type        = string
  default     = "db-f1-micro"
}

variable "db_disk_size_gb" {
  description = "Cloud SQL disk size in GB. Autoresize is on, so this is a floor."
  type        = number
  default     = 10
}

variable "db_availability_type" {
  description = "ZONAL or REGIONAL. Use REGIONAL for production."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.db_availability_type)
    error_message = "db_availability_type must be ZONAL or REGIONAL."
  }
}

variable "deletion_protection" {
  description = "Protect the Cloud SQL instance from deletion. Required for prod."
  type        = bool
  default     = false
}

variable "metabase_image" {
  description = "Metabase container image."
  type        = string
  default     = "metabase/metabase:v0.63.15.5"
}

variable "cpu_limit" {
  description = "Cloud Run CPU limit. Cloud Run requires at least 2 at 4Gi memory."
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Cloud Run memory limit. 2Gi OOMs during the first-boot schema migration."
  type        = string
  default     = "4Gi"
}

variable "java_opts" {
  description = "JVM options."
  type        = string
  default     = "-Xmx2500m"
}

variable "min_instances" {
  description = "Minimum Cloud Run instances. 0 scales to zero at the cost of a 60-90s cold start. Use 1 for production."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum Cloud Run instances."
  type        = number
  default     = 2
}

variable "allow_public_access" {
  description = "Grant roles/run.invoker to allUsers. Set false and use invoker_members to require IAM."
  type        = bool
  default     = true
}

variable "invoker_members" {
  description = "Additional IAM members granted roles/run.invoker."
  type        = list(string)
  default     = []
}
