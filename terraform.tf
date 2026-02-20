# Copyright IBM Corp. 2023

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