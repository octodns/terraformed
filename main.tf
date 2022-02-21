terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.20"
    }
  }
}

# Configure the GitHub Provider
provider "github" {}
