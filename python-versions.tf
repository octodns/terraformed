variable "python_versions_active" {
  type    = list(string)
  default = ["3.8", "3.9", "3.10", "3.11", "3.12"]
}
variable "python_version_current" {
  type    = string
  default = "3.11"
}

resource "null_resource" "required_contexts" {
  count = "${length(var.python_versions_active)}"

  triggers = {
    job = "ci (${element(var.python_versions_active, count.index)})"
  }
}
