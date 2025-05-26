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
    users  = optional(list(string))
    groups = optional(list(string))
    external_members = optional(list(string))
  }))
  default = {}
}

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

resource "freeipa_user_group_membership" "this" {
  depends_on = [freeipa_group.this]
  for_each = var.groups

  name  = each.key
  users = each.value.users
  groups = each.value.groups
  external_members = each.value.external_members
}
