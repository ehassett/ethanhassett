locals {
  objects_path = "${path.module}/objects"
  domain_names = ["ethanhassett.com", "ehassett.com"]
}

data "google_client_openid_userinfo" "this" {}

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

# CDN
resource "google_compute_global_address" "this" {
  name = "ethanhassett-com"
}

resource "google_compute_backend_bucket" "cdn" {
  name        = "ethanhassett-com-backend-bucket"
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

resource "google_compute_url_map" "cdn" {
  name            = "http-lb"
  default_service = google_compute_backend_bucket.cdn.id
}

resource "google_compute_target_http_proxy" "cdn" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.cdn.id
}

resource "google_compute_global_forwarding_rule" "cdn" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.cdn.id
  ip_address            = google_compute_global_address.this.id
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
resource "google_cloud_run_v2_service" "this" {
  name        = "ethanhassett-com"
  description = "Cloud Run service for ethanhassett.com"
  location    = "us-east5"
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = data.google_client_openid_userinfo.this.email
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
          memory = 4
          cpu    = 4
        }
      }
    }
  }
}
