terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # backend "gcs" {
  #   bucket = "coraline-tfstate-CHANGEME"
  #   prefix = "metabase/dev"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "cloudflare" {}
