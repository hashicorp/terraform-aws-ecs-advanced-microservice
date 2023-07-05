# Copyright (c) HashiCorp, Inc.

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }

    vault = {
      source                = "hashicorp/vault"
      configuration_aliases = [vault.dev, vault.prod]
    }
  }
}