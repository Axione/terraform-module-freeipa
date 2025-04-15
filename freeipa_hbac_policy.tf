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

##################################################################################
locals {
  hbac_policy_users = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "users" && members != null)])
  ])
  hbac_policy_user_groups = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "user_groups" && members != null)])
  ])

  hbac_policy_hosts = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "hosts" && members != null)])
  ])
  hbac_policy_host_groups = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "host_groups" && members != null)])
  ])

  hbac_policy_services = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "services" && members != null)])
  ])
  hbac_policy_service_groups = flatten([for key, value in var.hbac_policy :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "service_groups" && members != null)])
  ])
}


##################################################################################
output "hbac_policy" { value = var.hbac_policy }
output "hbac_policy_users" { value = local.hbac_policy_users }
output "hbac_policy_user_groups" { value = local.hbac_policy_user_groups }
output "hbac_policy_hosts" { value = local.hbac_policy_hosts }
output "hbac_policy_host_groups" { value = local.hbac_policy_host_groups }
output "hbac_policy_services" { value = local.hbac_policy_services }
output "hbac_policy_service_groups" { value = local.hbac_policy_service_groups }

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

resource "freeipa_hbac_policy_user_membership" "user" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_users : "${v.name}_-_${v.user}" => v }

  name = each.value.name
  user = each.value.user
}
resource "freeipa_hbac_policy_user_membership" "group" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_user_groups : "${v.name}_-_${v.group}" => v }

  name  = each.value.name
  group = each.value.group
}

resource "freeipa_hbac_policy_host_membership" "hosts" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_hosts : "${v.name}_-_${v.user}" => v }

  name = each.value.name
  host = each.value.user
}
resource "freeipa_hbac_policy_host_membership" "host_groups" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_host_groups : "${v.name}_-_${v.group}" => v }

  name      = each.value.name
  hostgroup = each.value.group
}

resource "freeipa_hbac_policy_service_membership" "services" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_services : "${v.name}_-_${v.user}" => v }

  name    = each.value.name
  service = each.value.user
}
resource "freeipa_hbac_policy_service_membership" "service_groups" {
  depends_on = [freeipa_hbac_policy.this]
  for_each   = { for k, v in local.hbac_policy_service_groups : "${v.name}_-_${v.group}" => v }

  name         = each.value.name
  servicegroup = each.value.group
}
