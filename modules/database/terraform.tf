# Copyright IBM Corp. 2023, 2026

terraform {
  required_providers {
    vault = {
      source                = "hashicorp/vault"
      configuration_aliases = [vault.dev, vault.prod]
    }
  }
}