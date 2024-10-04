locals {
  objects_path = "${path.module}/objects"
  domain_names = ["ethanhassett.com", "ehassett.com"]
  prefix       = "ethanhassett-com"
}

data "google_project" "this" {}

data "cloudflare_zone" "this" {
  for_each = toset(local.domain_names)
  name     = each.key
}

# Backend Storage Bucket
resource "google_storage_bucket" "this" {
  name          = local.domain_names[0]
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

resource "google_compute_network" "this" {
  name                    = "${local.prefix}-neg-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${local.prefix}-neg-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.this.id
}

resource "google_compute_network_endpoint_group" "this" {
  name                  = "${local.prefix}-neg"
  network               = google_compute_network.this.id
  subnetwork            = google_compute_subnetwork.this.id
  zone                  = "us-east5-a"
  network_endpoint_type = "SERVERLESS"
}

resource "google_compute_backend_service" "this" {
  name                  = "${local.prefix}-backend-service"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_network_endpoint_group.this.id
  }
}

resource "google_compute_backend_bucket" "this" {
  name        = "${local.prefix}-backend-bucket"
  description = "Backend bucket for ${local.domain_names[0]}"
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
# TODO: remove once applied
moved {
  from = google_compute_backend_bucket.cdn
  to   = google_compute_backend_bucket.this
}

resource "google_compute_url_map" "this" {
  name            = "http-lb" # TODO: add prefix
  default_service = google_compute_backend_service.this.id

  host_rule {
    hosts        = ["ethanhassett.com"]
    path_matcher = "site"
  }

  path_matcher {
    name            = "site"
    default_service = google_compute_backend_service.this.id

    path_rule {
      paths   = ["/static"]
      service = google_compute_backend_bucket.this.id
    }
  }
}
# TODO: remove once applied
moved {
  from = google_compute_url_map.cdn
  to   = google_compute_url_map.this
}

resource "google_compute_target_http_proxy" "this" {
  name    = "http-lb-proxy" # TODO: add prefix
  url_map = google_compute_url_map.this.id
}
# TODO: remove once applied
moved {
  from = google_compute_target_http_proxy.cdn
  to   = google_compute_target_http_proxy.this
}

resource "google_compute_global_forwarding_rule" "this" {
  name                  = "http-lb-forwarding-rule" # TODO: add prefix
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.this.id
  ip_address            = google_compute_global_address.this.id
}
# TODO: remove once applied
moved {
  from = google_compute_global_forwarding_rule.cdn
  to   = google_compute_global_forwarding_rule.this
}

# DNS
resource "cloudflare_record" "a" {
  zone_id = data.cloudflare_zone.this[local.domain_names[0]].zone_id # Use the first domain, which is ethanhassett.com
  name    = local.domain_names[0]
  content = google_compute_global_address.this.address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "cname" {
  for_each = toset(local.domain_names)

  zone_id = data.cloudflare_zone.this[each.key].zone_id
  name    = "www"
  content = each.key
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
  description = "Cloud Run service for ethanhassett.com"
  location    = "us-east5"
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
