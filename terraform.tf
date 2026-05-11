# Copyright IBM Corp. 2023, 2026

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    github = {
      source = "integrations/github"
    }

    datadog = {
      source = "DataDog/datadog"
    }

    vault = {
      source = "hashicorp/vault"
    }
  }
}