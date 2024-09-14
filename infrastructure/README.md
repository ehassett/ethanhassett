# ethanhassett.com

OpenTofu codebase for https://ethanhassett.com.

# Contents

- [ethanhassett.com](#ethanhassettcom)
- [Contents](#contents)
- [Best Practices](#best-practices)
- [Tofu Documentation](#tofu-documentation)

# Best Practices

- Follow [the Terraform best practices](https://www.terraform-best-practices.com) as close as possible.
- Follow [conventional commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

# Tofu Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_hcp"></a> [hcp](#requirement\_hcp) | ~> 0.79 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.41.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 6.2.0 |
| <a name="provider_hcp"></a> [hcp](#provider\_hcp) | 0.95.1 |

## Inputs

No inputs.

## Outputs

No outputs.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_record.a](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.cname](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [google_compute_backend_bucket.cdn](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket) | resource |
| [google_compute_global_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.cdn](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_target_http_proxy.cdn](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_url_map.cdn](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.img](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_managed_folder.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_managed_folder) | resource |
| [google_storage_managed_folder_iam_binding.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_managed_folder_iam_binding) | resource |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |
| [hcp_vault_secrets_secret.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/data-sources/vault_secrets_secret) | data source |
| [hcp_vault_secrets_secret.google_credentials](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/data-sources/vault_secrets_secret) | data source |
<!-- END_TF_DOCS -->
