locals {
  region  = "us-east1"
  project = "ethanhassett"
  domain  = "ethanhassett.com"
}

data "cloudflare_zone" "this" {
  name = local.domain
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
      image = "docker.io/hassett/ethanhassett:0.0.2"

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

resource "google_cloud_run_service_iam_binding" "this" {
  location = google_cloud_run_v2_service.this.location
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]

  #checkov:skip=CKV_GCP_102:everyone should be able to access the site
}

# DNS
# resource "cloudflare_record" "this" {
#   for_each = google_cloud_run_domain_mapping.this.status[0].resource_records

#   zone_id = data.cloudflare_zone.this.zone_id
#   name    = each.value.name
#   content = each.value.rrdata
#   type    = each.value.type
#   ttl     = 300
# }
