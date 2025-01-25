terraform {
  required_version = "~> 1.8"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.79"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

data "hcp_vault_secrets_secret" "cloudflare_api_token" {
  app_name    = "platform-admin"
  secret_name = "CLOUDFLARE_API_TOKEN"
}

data "hcp_vault_secrets_secret" "google_credentials" {
  app_name    = "platform-admin"
  secret_name = "GOOGLE_CREDENTIALS"
}

provider "cloudflare" {
  api_token = data.hcp_vault_secrets_secret.cloudflare_api_token.secret_value
}

provider "google" {
  project     = local.project
  region      = local.region
  credentials = data.hcp_vault_secrets_secret.google_credentials.secret_value

  default_labels = {
    repo = "ethanhassett"
  }
}
