locals {
  objects_path = "${path.module}/objects"
  domain_name  = "ethanhassett.com"
  prefix       = "ethanhassett-com"
  region       = "us-east5"
}

data "google_project" "this" {}

data "cloudflare_zone" "this" {
  name = local.domain_name
}

# Backend Storage Bucket
resource "google_storage_bucket" "this" {
  name          = local.domain_name
  location      = "US"
  storage_class = "STANDARD"

  force_destroy               = false
  uniform_bucket_level_access = true

  #checkov:skip=CKV_GCP_62:no need for access logs at this time
  #checkov:skip=CKV_GCP_78:no need for versioning at this time
  #checkov:skip=CKV_GCP_114:no need for public_access_prevention at this time
}

resource "google_storage_bucket_object" "img" {
  for_each = fileset("${local.objects_path}/img", "*")

  bucket = google_storage_bucket.this.name
  name   = "public/img/${each.key}"
  source = "${local.objects_path}/img/${each.key}"
}

resource "google_storage_managed_folder" "public" {
  bucket        = google_storage_bucket.this.name
  name          = "public/"
  force_destroy = false
}

resource "google_storage_managed_folder_iam_binding" "public" {
  bucket         = google_storage_managed_folder.public.bucket
  managed_folder = google_storage_managed_folder.public.name
  role           = "roles/storage.objectViewer"
  members        = ["allUsers"]
}

# Networking
resource "google_compute_global_address" "this" {
  name = local.prefix
}

resource "google_compute_region_network_endpoint_group" "this" {
  name                  = "${local.prefix}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = local.region

  cloud_run {
    service = google_cloud_run_v2_service.this.name
  }
}

resource "google_compute_backend_service" "this" {
  name                  = "${local.prefix}-backend-service"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.this.id
  }
}

resource "google_compute_backend_bucket" "this" {
  name        = "${local.prefix}-backend-bucket"
  description = "Backend bucket for ${local.domain_name}"
  bucket_name = google_storage_bucket.this.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

resource "google_compute_url_map" "this" {
  name            = "${local.prefix}-url-map"
  default_service = google_compute_backend_service.this.id

  host_rule {
    hosts        = [local.domain_name]
    path_matcher = "site"
  }

  path_matcher {
    name            = "site"
    default_service = google_compute_backend_service.this.id

    path_rule {
      paths   = ["/public/*"]
      service = google_compute_backend_bucket.this.id
    }
  }
}

resource "google_compute_target_http_proxy" "this" {
  name    = "${local.prefix}-http-proxy"
  url_map = google_compute_url_map.this.id
}

resource "google_compute_global_forwarding_rule" "this" {
  name                  = "${local.prefix}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.this.id
  ip_address            = google_compute_global_address.this.id
}

# DNS
resource "cloudflare_record" "a" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = local.domain_name
  content = google_compute_global_address.this.address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "cname" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "www"
  content = local.domain_name
  type    = "CNAME"
  ttl     = 300
}

# Cloud Run
resource "google_service_account" "this" {
  account_id   = "cloudrun"
  display_name = "cloudrun"
  description  = "Service account for Cloud Run"
}

resource "google_project_iam_binding" "cloud_run_admin" {
  project = data.google_project.this.project_id
  role    = "roles/run.admin"
  members = ["serviceAccount:${google_service_account.this.email}"]
}

resource "google_project_iam_binding" "service_account_user" {
  project = data.google_project.this.project_id
  role    = "roles/iam.serviceAccountUser"
  members = ["serviceAccount:${google_service_account.this.email}"]

  #checkov:skip=CKV_GCP_41:project-scoped roles are fine at this time
  #checkov:skip=CKV_GCP_49:basic roles are fine at this time
}

resource "google_cloud_run_v2_service" "this" {
  name        = local.prefix
  description = "Cloud Run service for ${local.domain_name}"
  location    = local.region
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = google_service_account.this.email
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 1000

    containers {
      image = "docker.io/hassett/ethanhassett-com:0.0.1"

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

resource "google_cloud_run_service_iam_binding" "this" {
  location = google_cloud_run_v2_service.this.location
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]

  #checkov:skip=CKV_GCP_102:everyone should be able to access the site
}
