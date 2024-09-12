resource "google_storage_bucket" "this" {
  name     = "ethanhassett.com"
  location = "US"

  force_destroy = false
  storage_class = "STANDARD"
}

resource "google_storage_bucket_access_control" "allow_public_read_access" {
  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_default_object_access_control" "allow_public_read_access" {
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "icons" {
  for_each = fileset("${path.module}/objects/icons", "*")

  bucket = google_storage_bucket.this.name
  name   = "icons/${each.key}"
  source = "${path.module}/objects/icons/${each.key}"
}
