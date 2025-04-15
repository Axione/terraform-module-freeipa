##################################################################################
# Create groups
# Add users or other groups inside this groups
variable "groups" {
  type = map(object({
    addattr     = optional(list(string))
    description = optional(string)
    external    = optional(bool)
    gid_number  = optional(number)
    nonposix    = optional(bool)
    setattr     = optional(list(string))
  }))
  default = {}
}

variable "groups_membership" {
  type = map(object({
    group = optional(list(string))
    user  = optional(list(string))
  }))
  default = {}
}

##################################################################################
locals {
  user_groups_membership = flatten([for key, value in var.groups_membership :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user }
    ] if(type == "user" && members != null)])
  ])
  group_groups_membership = flatten([for key, value in var.groups_membership :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user }
    ] if(type == "group" && members != null)])
  ])

}

output "groups_membership" { value = var.groups_membership }
output "user_groups_membership" { value = local.user_groups_membership }
output "group_groups_membership" { value = local.group_groups_membership }

##################################################################################
resource "freeipa_group" "this" {
  for_each = var.groups

  name        = each.key
  addattr     = each.value.addattr
  description = each.value.description
  external    = each.value.external
  gid_number  = each.value.gid_number
  nonposix    = each.value.nonposix
  setattr     = each.value.setattr
}

resource "freeipa_user_group_membership" "user" {
  depends_on = [freeipa_group.this, freeipa_user.this]
  for_each   = { for k, v in local.user_groups_membership : "${v.name}_-_${v.user}" => v }

  name = each.value.name
  user = each.value.user
}

resource "freeipa_user_group_membership" "group" {
  depends_on = [freeipa_group.this]
  for_each   = { for k, v in local.group_groups_membership : "${v.name}_-_${v.group}" => v }

  name  = each.value.name
  group = each.value.group
}
