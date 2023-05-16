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

  cloud {
    organization = "hcp_waypoint_integration"
    workspaces {
      name = "the-microservice"
    }
  }
}