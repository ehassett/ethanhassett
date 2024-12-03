locals {
  region  = "us-east1"
  project = "ethanhassett"
  domain  = "ethanhassett.com"

  # Due to limitations with the Google Cloud Run Domain Mapping API, these IPs are hardcoded here from the domain mapping settings
  a_record_ips    = ["216.239.32.21", "216.239.34.21", "216.239.36.21", "216.239.38.21"]
  aaaa_record_ips = ["2001:4860:4802:32::15", "2001:4860:4802:34::15", "2001:4860:4802:36::15", "2001:4860:4802:38::15"]
}

data "cloudflare_zone" "this" {
  name = local.domain
}

# Artifact Registry
resource "google_artifact_registry_repository" "this" {
  repository_id = local.project
  description   = "Docker repository for ${local.domain}"
  location      = local.region
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }

  cleanup_policies {
    id     = "keep-latest-2-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count            = 2
      package_name_prefixes = [local.project]
    }
  }

  cleanup_policies {
    id     = "keep-latest-tag"
    action = "KEEP"
    condition {
      tag_state             = "TAGGED"
      tag_prefixes          = ["latest"]
      package_name_prefixes = [local.project]
    }
  }

  cleanup_policies {
    id     = "delete-after-30-days"
    action = "DELETE"
    condition {
      tag_state             = "TAGGED"
      older_than            = "2592000s"
      package_name_prefixes = [local.project]
    }
  }

  #checkov:skip=CKV_GCP_84:CSEK not necessary at this time
}

# Cloud Run
resource "google_service_account" "cloud_run" {
  account_id   = "cloudrun"
  display_name = "cloudrun"
  description  = "Service account for Cloud Run"
}

resource "google_project_iam_binding" "cloud_run_admin" {
  project = local.project
  role    = "roles/run.admin"
  members = ["serviceAccount:${google_service_account.cloud_run.email}"]
}

resource "google_project_iam_binding" "service_account_user" {
  project = local.project
  role    = "roles/iam.serviceAccountUser"
  members = ["serviceAccount:${google_service_account.cloud_run.email}"]

  #checkov:skip=CKV_GCP_41:project-scoped roles are fine at this time
  #checkov:skip=CKV_GCP_49:basic roles are fine at this time
}

resource "google_cloud_run_v2_service" "this" {
  name        = local.project
  description = "Cloud Run service for ${local.domain}"
  location    = local.region
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = google_service_account.cloud_run.email
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 1000

    containers {
      image = "us-east1-docker.pkg.dev/ethanhassett/ethanhassett/ethanhassett:0.1.2"

      ports {
        container_port = 4321
      }

      resources {
        cpu_idle = true
        limits = {
          memory = "1024Mi"
          cpu    = "2"
        }
      }
    }
  }

  depends_on = [google_artifact_registry_repository.this]
}

resource "google_cloud_run_domain_mapping" "this" {
  name     = local.domain
  location = google_cloud_run_v2_service.this.location

  metadata {
    namespace = local.project
  }

  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}

resource "google_cloud_run_domain_mapping" "www" {
  name     = "www.${local.domain}"
  location = google_cloud_run_v2_service.this.location

  metadata {
    namespace = local.project
  }

  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}

resource "google_cloud_run_service_iam_binding" "this" {
  location = google_cloud_run_v2_service.this.location
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]

  #checkov:skip=CKV_GCP_102:everyone should be able to access the site
}

# DNS
resource "cloudflare_record" "a" {
  for_each = toset(local.a_record_ips)

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "@"
  content = each.key
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "aaaa" {
  for_each = toset(local.aaaa_record_ips)

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "@"
  content = each.key
  type    = "AAAA"
  ttl     = 300
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "www"
  content = "ghs.googlehosted.com."
  type    = "CNAME"
  ttl     = 300
}
