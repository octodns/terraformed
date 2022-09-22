terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.2"
    }
  }
}

# Configure the GitHub Provider
provider "github" {}
