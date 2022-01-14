# admins

resource "github_membership" "admins" {
  for_each = toset([
    "ross",
    "theojulienne",
    "yeled",
  ])

  username = each.key
  role     = "admin"
}

# Members

resource "github_membership" "members" {
  for_each = toset([
    "awlx",
    "parkr",
    "viranch",
    "yzguy",
  ])

  username = each.key
  role     = "member"
}
