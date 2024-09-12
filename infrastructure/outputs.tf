output "img_urls" {
  description = "Media URLs for objects in img folder."
  value       = { for obj in google_storage_bucket_object.img : obj.name => obj.media_link }
}
