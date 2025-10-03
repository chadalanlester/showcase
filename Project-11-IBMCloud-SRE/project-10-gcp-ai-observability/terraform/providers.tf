terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google      = { source = "hashicorp/google", version = ">= 5.30.0" }
    google-beta = { source = "hashicorp/google-beta", version = ">= 5.30.0" }
    kubernetes  = { source = "hashicorp/kubernetes", version = ">= 2.27.0" }
    helm        = { source = "hashicorp/helm", version = ">= 3.0.0" }
    null        = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

# IMPORTANT: prefix endpoint with https://
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
  # pin repo state locally
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  repository_cache       = "${path.module}/.helm/cache"
}

