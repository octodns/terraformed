resource "github_team" "review" {
  name        = "review"
  description = "Team to group people who do general octoDNS reviews"
  privacy     = "closed"
}

resource "github_team_membership" "review-maintainer" {
  for_each = toset([
    "ross",
  ])

  team_id  = github_team.review.id
  username = each.key
  role     = "maintainer"
}

resource "github_team_membership" "review-member" {
  for_each = toset([
    "viranch",
    "yzguy",
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
