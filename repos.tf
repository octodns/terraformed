
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
    "octodns-docker" = "",
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
    "octodns-powerdns" = "PowerDNS API provider for octoDNS",
    "octodns-route53" = "AWS Route53 provider for octoDNS",
    "octodns-template" = "Skeletal new module template and helper script",
    "terraformed" = "Terraform based management of the octoDNS GitHub Org",
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
    # can't set this to 0 until https://github.com/integrations/terraform-provider-github/pull/971
    # is released. when that's the case the lifecycle ignore below can go away
    # as well
    #required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = []
    strict   = true
  }

  lifecycle {
    ignore_changes = [required_pull_request_reviews[0].required_approving_review_count]
  }
}

resource "github_branch_protection" "repo" {
  for_each = var.repos

  repository_id = github_repository.repo[each.key].node_id

  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = false
  pattern                         = "main"
  require_conversation_resolution = false
  require_signed_commits          = false
  required_linear_history         = false

  push_restrictions               = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    # can't set this to 0 until https://github.com/integrations/terraform-provider-github/pull/971
    # is released. when that's the case the lifecycle ignore below can go away
    # as well
    #required_approving_review_count = 0
    restrict_dismissals             = false
  }

  required_status_checks {
    contexts = []
    strict   = true
  }

  lifecycle {
    ignore_changes = [required_pull_request_reviews[0].required_approving_review_count]
  }
}
