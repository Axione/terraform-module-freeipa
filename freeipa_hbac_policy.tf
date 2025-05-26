##################################################################################
variable "hbac_policy" {
  type = map(object({
    description    = optional(string)
    enabled        = optional(bool, true)
    users          = optional(list(string), [])
    user_groups    = optional(list(string))
    hosts          = optional(list(string), [])
    host_groups    = optional(list(string))
    services       = optional(list(string), ["all"])
    service_groups = optional(list(string))
  }))
  default = {}
}

###################################################################################
resource "freeipa_hbac_policy" "this" {
  for_each = var.hbac_policy

  name        = each.key
  description = each.value.description
  enabled     = each.value.enabled

  usercategory    = contains(each.value.users, "all") ? "all" : null
  hostcategory    = contains(each.value.hosts, "all") ? "all" : null
  servicecategory = contains(each.value.services, "all") ? "all" : null
}

resource "freeipa_hbac_policy_user_membership" "this" {
  depends_on = [freeipa_hbac_policy.this]
  for_each = var.hbac_policy

  name = each.key
  users = each.value.users
  groups = each.value.user_groups
}

resource "freeipa_hbac_policy_host_membership" "this" {
  depends_on = [freeipa_hbac_policy.this]
  for_each = var.hbac_policy

  name = each.key
  hosts = each.value.hosts
  hostgroups = each.value.host_groups
}

resource "freeipa_hbac_policy_service_membership" "services" {
  depends_on = [freeipa_hbac_policy.this]
  for_each = var.hbac_policy

  name    = each.key
  services = each.value.services
  servicegroups = each.value.service_groups
}
