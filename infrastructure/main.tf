resource "google_storage_bucket" "this" {
  name     = "ethanhassett.com"
  location = "US"

  force_destroy = false
  storage_class = "STANDARD"

  #checkov:skip=CKV_GCP_29:no need for uniform_bucket_level_access at this time
  #checkov:skip=CKV_GCP_62:no need for access logs at this time
  #checkov:skip=CKV_GCP_78:no need for versioning at this time
  #checkov:skip=CKV_GCP_114:no need for public_access_prevention at this time
}

resource "google_storage_bucket_access_control" "allow_public_read_access" {
  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_default_object_access_control" "allow_public_read_access" {
  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "icons" {
  for_each = fileset("${path.module}/objects/icons", "*")

  bucket = google_storage_bucket.this.name
  name   = "icons/${each.key}"
  source = "${path.module}/objects/icons/${each.key}"
}