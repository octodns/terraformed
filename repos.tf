variable "repos" {
  type = map(string)
  default = {
    # providers
    "octodns-autodns" = "octodns Provider for AutoDNS by InternetX",
    "octodns-azure" = "Azure DNS provider for octoDNS",
    "octodns-bind" = "RFC compliant (Bind9) provider for octoDNS",
    "octodns-cloudflare" = "Cloudflare DNS provider for octoDNS",
    "octodns-constellix" = "Constellix DNS provider for octoDNS",
    "octodns-ddns" = "A simple Dynamic DNS source for octoDNS.",
    "octodns-digitalocean" = "DigitalOcean DNS provider for octoDNS",
    "octodns-dnsimple" = "Dnsimple API provider for octoDNS",
    "octodns-dnsmadeeasy" = "DnsMadeEasy DNS provider for octoDNS",
    "octodns-edgecenter" = "EdgeCenter provider for octoDNS",
    "octodns-easydns" = "easyDNS API v3 provider for octoDNS",
    "octodns-edgedns" = "Akamai Edge DNS provider for octoDNS",
    "octodns-etchosts" = "/etc/hosts provider for octoDNS",
    "octodns-fastly" = "Fastly DNS source for octoDNS",
    "octodns-gandi" = "Gandi v5 API provider for octoDNS",
    "octodns-gcore" = "G-Core Labs DNS v2 API provider for octoDNS",
    "octodns-googlecloud" = "Google Cloud DNS provider for octoDNS",
    "octodns-hetzner" = "Hetzner DNS provider for octoDNS",
    "octodns-keyring" = "keyring Secrets Handler support for octoDNS",
    "octodns-mythicbeasts" = "Mythic Beasts DNS provider for octoDNS",
    "octodns-ns1" = "Ns1Provider provider for octoDNS",
    "octodns-ovh" = "OVHcloud DNS v6 API provider for octoDNS",
    "octodns-powerdns" = "PowerDNS API provider for octoDNS",
    "octodns-rackspace" = "Rackspace DNS v1 API provider for octoDNS",
    "octodns-route53" = "AWS Route53 provider for octoDNS",
    "octodns-selectel" = "Selectel DNS provider for octoDNS",
    "octodns-spf" = "SPF Management Utilities/Source for octoDNS",
    "octodns-template" = "Skeletal new module template and helper script",
    "octodns-transip" = "Transip DNS provider for octoDNS",
    "octodns-ultra" = "Ultra DNS provider for octoDNS",

    # other
    ".github" = "Org-level configuration & defaults",
    "octodns-docker" = "OctoDNS – DNS as code – bundled as Docker images",
    "terraformed" = "Terraform based management of the octoDNS GitHub Org",
  }
}

variable "repos_providers" {
  type = set(string)
  default = [
    "octodns-autodns",
    "octodns-azure",
    "octodns-bind",
    "octodns-cloudflare",
    "octodns-constellix",
    "octodns-ddns",
    "octodns-digitalocean",
    "octodns-dnsimple",
    "octodns-dnsmadeeasy",
    "octodns-edgecenter",
    "octodns-easydns",
    "octodns-edgedns",
    "octodns-etchosts",
    "octodns-fastly",
    "octodns-gandi",
    "octodns-gcore",
    "octodns-googlecloud",
    "octodns-hetzner",
    "octodns-keyring",
    "octodns-mythicbeasts",
    "octodns-ns1",
    "octodns-ovh",
    "octodns-powerdns",
    "octodns-rackspace",
    "octodns-route53",
    "octodns-selectel",
    "octodns-spf",
    "octodns-template",
    "octodns-transip",
    "octodns-ultra",
  ]
}

variable "repos_archived" {
  type = set(string)
  default = [
    "octodns-dyn",
  ]
}

variable "repos_other" {
  type = set(string)
  default = [
    ".github",
    "octodns-docker",
    "terraformed",
  ]
}

resource "github_repository" "octodns" {
  name        = "octodns"
  description = "Tools for managing DNS across multiple providers"

  delete_branch_on_merge = true
  has_downloads          = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  visibility             = "public"
  vulnerability_alerts   = true

  topics = [
    "dns",
    "infrastructure-as-code",
    "workflow",
  ]
}

resource "github_repository" "repo" {
  for_each = var.repos

  name        = each.key
  description = each.value

  delete_branch_on_merge = true
  has_downloads          = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  visibility             = "public"
  vulnerability_alerts   = !contains(var.repos_archived, each.key)

  archived               = contains(var.repos_archived, each.key)

  lifecycle {
    # don't want to bother with managing topics atm
    ignore_changes = [topics]
  }
}

# TODO: look at refactoring this into the std repo now that it's main
resource "github_branch_protection" "octodns" {
  repository_id = github_repository.octodns.node_id

  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = true
  pattern                         = "main"
  require_conversation_resolution = false
  require_signed_commits          = false
  required_linear_history         = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = concat("${null_resource.required_contexts.*.triggers.job}", ["setup-py"])
    strict   = true
  }
}

resource "github_repository_ruleset" "octodns" {
  repository = github_repository.octodns.name

  name        = "version-tags"
  target      = "tag"
  enforcement = "active"

  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    creation            = true
    update              = true
    deletion            = true
  }
}

resource "github_branch_protection" "repo" {
  for_each = var.repos

  repository_id = github_repository.repo[each.key].node_id

  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = true
  pattern                         = "main"
  require_conversation_resolution = false
  require_signed_commits          = false
  required_linear_history         = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = contains(var.repos_providers, each.key) ? concat("${null_resource.required_contexts.*.triggers.job}", ["setup-py"]) : []
    strict   = true
  }
}

resource "github_repository_ruleset" "repo" {
  for_each = var.repos

  repository = github_repository.repo[each.key].name

  name        = "version-tags"
  target      = "tag"
  enforcement = "active"

  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    creation            = true
    update              = true
    deletion            = true
  }
}
