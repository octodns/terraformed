# Adopt the vulnerability alert settings previously managed through
# github_repository.vulnerability_alerts. Safe to delete once applied.

import {
  to = github_repository_vulnerability_alerts.octodns
  id = "octodns"
}

import {
  for_each = local.repos_active

  to = github_repository_vulnerability_alerts.repo[each.key]
  id = each.key
}
