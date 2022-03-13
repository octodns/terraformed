
variable "repos" {
  type = map(string)
  default = {
    "octodns-azure" = "Azure DNS provider for octoDNS",
    "octodns-cloudflare" = "Cloudflare DNS provider for octoDNS",
    "octodns-constellix" = "Constellix DNS provider for octoDNS",
    "octodns-ddns" = "A simple Dynamic DNS source for octoDNS.",
    "octodns-digitalocean" = "DigitalOcean DNS provider for octoDNS",
    "octodns-dnsimple" = "Dnsimple API provider for octoDNS",
    "octodns-dnsmadeeasy" = "DnsMadeEasy DNS provider for octoDNS",
    "octodns-docker" = "OctoDNS – DNS as code – bundled as Docker images",
    "octodns-dyn" = "[DEPRECATED] Oracle Dyn provider for octoDNS",
    "octodns-easydns" = "easyDNS API v3 provider for octoDNS",
    "octodns-edgedns" = "Akamai Edge DNS provider for octoDNS",
    "octodns-etchosts" = "/etc/hosts provider for octoDNS",
    "octodns-gandi" = "Gandi v5 API provider for octoDNS",
    "octodns-gcore" = "G-Core Labs DNS v2 API provider for octoDNS",
    "octodns-googlecloud" = "Google Cloud DNS provider for octoDNS",
    "octodns-hetzner" = "Hetzner DNS provider for octoDNS",
    "octodns-mythicbeasts" = "Mythic Beasts DNS provider for octoDNS",
    "octodns-ns1" = "Ns1Provider provider for octoDNS",
    "octodns-ovh" = "OVHcloud DNS v6 API provider for octoDNS",
    "octodns-powerdns" = "PowerDNS API provider for octoDNS",
    "octodns-rackspace" = "Rackspace DNS v1 API provider for octoDNS",
    "octodns-route53" = "AWS Route53 provider for octoDNS",
    "octodns-selectel" = "Selectel DNS provider for octoDNS",
    "octodns-template" = "Skeletal new module template and helper script",
    "octodns-transip" = "Transip DNS provider for octoDNS",
    "octodns-ultra" = "Ultra DNS provider for octoDNS",
    "terraformed" = "Terraform based management of the octoDNS GitHub Org",
  }
}

variable "required_contexts" {
  type = map(list(string))
  default = {
    "octodns-dyn" = ["ci (3.7)", "ci (3.8)", "ci (3.9)"],
    "octodns-ovh" = ["ci (3.7)", "ci (3.8)", "ci (3.9)"],
    "terraformed" = [],
  }
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
  vulnerability_alerts   = true

  lifecycle {
    # don't want to bother with managing topics atm
    ignore_changes = [topics]
  }
}

resource "github_branch_protection" "octodns" {
  repository_id = github_repository.octodns.node_id

  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = true
  pattern                         = "master"
  require_conversation_resolution = false
  require_signed_commits          = false
  required_linear_history         = false

  push_restrictions               = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = [
        "ci (3.7)",
        "ci (3.8)",
        "ci (3.9)",
        "ci (3.10)",
        "ci (octodns/octodns-azure)",
        "ci (octodns/octodns-cloudflare)",
        "ci (octodns/octodns-constellix)",
        "ci (octodns/octodns-ddns)",
        "ci (octodns/octodns-digitalocean)",
        "ci (octodns/octodns-dnsimple)",
        "ci (octodns/octodns-dnsmadeeasy)",
        "ci (octodns/octodns-docker)",
        "ci (octodns/octodns-dyn)",
        "ci (octodns/octodns-easydns)",
        "ci (octodns/octodns-edgedns)",
        "ci (octodns/octodns-etchosts)",
        "ci (octodns/octodns-gandi)",
        "ci (octodns/octodns-gcore)",
        "ci (octodns/octodns-googlecloud)",
        "ci (octodns/octodns-hetzner)",
        "ci (octodns/octodns-mythicbeasts)",
        "ci (octodns/octodns-ns1)",
        "ci (octodns/octodns-ovh)",
        "ci (octodns/octodns-powerdns)",
        "ci (octodns/octodns-rackspace)",
        "ci (octodns/octodns-route53)",
        "ci (octodns/octodns-selectel)",
        "ci (octodns/octodns-template)",
        "ci (octodns/octodns-transip)",
        "ci (octodns/octodns-ultra)",
    ]
    strict   = true
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

  push_restrictions               = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = lookup(var.required_contexts, each.key, [
      "ci (3.7)",
      "ci (3.8)",
      "ci (3.9)",
      "ci (3.10)",
    ])
    strict   = true
  }
}
