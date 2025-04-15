##################################################################################
# We can define:
#     - sudo_cmd separately
#     - sudo_cmd_group with list of commands membership 
# we create all commands from a merged list from the ones in sudo_cmd and the ones found in sudo_cmd_group
# We create all the groups then
# we finally assign commands to group

variable "sudo_cmd" {
  type    = list(string)
  default = []
}

variable "sudo_cmd_group" {
  type = map(object({
    description = optional(string)
    commands    = optional(list(string))
  }))
  default = {}
}

##################################################################################
locals {
  flatten_sudo_cmd_group = flatten([
    for policy, users in var.sudo_cmd_group : [
      for sev in users.commands : {
        name    = policy
        command = sev
      }
    ]
  ])

  sudo_cmd_group_list = distinct(flatten([
    for k, v in var.sudo_cmd_group : [
      v.commands
    ]
  ]))
}

output "flatten_sudo_cmd_group" { value = local.flatten_sudo_cmd_group }
output "sudo_cmd_list" { value = local.sudo_cmd_group_list }

###################################################################################
resource "freeipa_sudo_cmd" "this" {
  for_each = toset(distinct(concat(var.sudo_cmd, local.sudo_cmd_group_list)))
  name     = each.key
}

resource "freeipa_sudo_cmdgroup" "this" {
  depends_on  = [freeipa_sudo_cmd.this]
  for_each    = var.sudo_cmd_group
  name        = each.key
  description = each.value.description
}

resource "freeipa_sudo_cmdgroup_membership" "this" {
  depends_on = [freeipa_sudo_cmdgroup.this]
  for_each   = { for k, v in local.flatten_sudo_cmd_group : "${v.name}_-_${v.command}" => v }
  name       = each.value.name
  sudocmd    = each.value.command
}
