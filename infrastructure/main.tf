locals {
  objects_path = "${path.module}/objects"
  domain_names = ["ethanhassett.com", "ehassett.com"]
}

data "cloudflare_zone" "ethanhassett_com" {
  for_each = toset(local.domain_names)
  name     = each.key
}
# TODO: rmove after apply
moved {
  from = cloudflare_zone.ethanhassett_com
  to   = cloudflate_zone.this["ethanhassett.com"]
}

# Backend Storage Bucket
resource "google_storage_bucket" "this" {
  name          = local.domain_name[0]
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
  description = "Backend bucket for ${local.domain_name[0]}"
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
  zone_id = data.cloudflare_zone.ethanhassett_com.zone_id
  name    = local.domain_name[0]
  content = google_compute_global_address.this.address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "cname" {
  for_each = toset([local.domain_names])

  zone_id = data.cloudflare_zone.this[each.key].zone_id
  name    = "www"
  content = each.key
  type    = "CNAME"
  ttl     = 300
}
