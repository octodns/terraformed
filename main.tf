variable "state_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase used to encrypt the state and plan files (TF_VAR_state_passphrase)"
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
  }

  # State is committed to the repo, so it must be encrypted.
  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }

    state {
      method   = method.aes_gcm.main
      enforced = true
    }

    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}

# Configure the GitHub Provider
provider "github" {}
