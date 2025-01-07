resource "github_team" "review" {
  name        = "review"
  description = "Team to group people who do general octoDNS reviews"
  privacy     = "closed"
}

resource "github_team_membership" "review-maintainer" {
  for_each = toset([
    "ross",
    "yzguy",
  ])

  team_id  = github_team.review.id
  username = each.key
  role     = "maintainer"
}

resource "github_team_membership" "review-member" {
  for_each = toset([
    "istr",
    "viranch",
  ])

  team_id  = github_team.review.id
  username = each.key
  role     = "member"
}

resource "github_team_repository" "review-octodns" {
  team_id    = github_team.review.id
  repository = "octodns"
  permission = "maintain"
}

resource "github_team_repository" "review" {
  for_each   = var.repos

  team_id    = github_team.review.id
  repository = each.key
  permission = "maintain"
}

# AutoDNS

resource "github_team" "autodns" {
  name        = "autodns"
  description = "Team to group people who manage octodns-autodns"
  privacy     = "closed"
}

resource "github_team_membership" "autodns" {
  for_each = toset([
    "avalor1",
    "neubi4",
    "xFuture603",
    "z-bsod"
  ])

  team_id  = github_team.autodns.id
  username = each.key
  role     = "member"
}

resource "github_team_repository" "autodns" {
  team_id    = github_team.autodns.id
  repository = github_repository.repo["octodns-autodns"].id
  permission = "maintain"
}
