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
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_hcp"></a> [hcp](#requirement\_hcp) | ~> 0.79 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |
| <a name="provider_hcp"></a> [hcp](#provider\_hcp) | ~> 0.79 |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_img_urls"></a> [img\_urls](#output\_img\_urls) | Media URLs for objects in img folder. |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_access_control.public_read_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_access_control) | resource |
| [google_storage_bucket_object.img](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_default_object_access_control.public_read_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_default_object_access_control) | resource |
| [hcp_vault_secrets_secret.google_credentials](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/data-sources/vault_secrets_secret) | data source |
<!-- END_TF_DOCS -->
