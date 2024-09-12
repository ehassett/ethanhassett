output "icon_url" {
  description = "Media URL for icon objects."
  value       = { for obj in google_storage_bucket_object.icons : obj.name => obj.media_link }
}
