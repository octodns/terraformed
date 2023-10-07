data "http" "ci_config" {
  url = "https://github.com/octodns/octodns/raw/main/.ci-config.json"
}

locals {
  ci_config = jsondecode(data.http.ci_config.body)
  python_versions_active = local.ci_config.python_versions_active
  python_version_current = local.ci_config.python_version_current
}

variable "python_version_current" {
  type    = string
  default = "3.11"
}

resource "null_resource" "required_contexts" {
  count = "${length(local.python_versions_active)}"

  triggers = {
    job = "ci (${element(local.python_versions_active, count.index)})"
  }
}
