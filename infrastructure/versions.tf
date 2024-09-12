terraform {
  required_version = "~> 1.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.79"
    }
  }
}

data "hcp_vault_secrets_secret" "google_credentials" {
  app_name    = "spacelift"
  secret_name = "GOOGLE_CREDENTIALS_ETHANHASSETT"
}

provider "google" {
  project     = "ethanhassett"
  region      = "us-east5"
  credentials = data.hcp_vault_secrets_secret.google_credentials.secret_value

  default_labels = {
    repo = "ehassett/ethanhassett.com"
  }
}
