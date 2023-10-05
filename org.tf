resource "github_actions_organization_variable" "python_versions_active" {
  variable_name   = "PYTHON_VERSIONS_ACTIVE"
  visibility      = "all"
  value           = jsonencode(var.python_versions_active)
}

resource "github_actions_organization_variable" "python_version_current" {
  variable_name   = "PYTHON_VERSION_CURRENT"
  visibility      = "all"
  value           = var.python_version_current
}
