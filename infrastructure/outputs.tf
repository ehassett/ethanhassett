output "img_urls" {
  description = "URLs for objects in public/img."
  value       = { for obj in google_storage_bucket_object.img : obj.name => obj.self_link }
}
