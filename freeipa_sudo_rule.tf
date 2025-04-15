##################################################################################
variable "sudo_rules" {
  type = map(object({
    description         = optional(string)
    enabled             = optional(bool, true)
    order               = optional(number)
    sudo_option         = optional(string, "!authenticate")
    users               = optional(list(string), [])
    user_groups         = optional(list(string))
    hosts               = optional(list(string), [])
    host_groups         = optional(list(string))
    commands            = optional(list(string), [])
    command_groups      = optional(list(string))
    commands_deny       = optional(list(string), [])
    command_groups_deny = optional(list(string))
    runasusers          = optional(list(string), [])
    #runasuser_groups     = optional(list(string), [])
    runasgroups = optional(list(string), [])
  }))
  default = {}
}

##################################################################################
locals {
  sudo_rule_users = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "users" && members != null)])
  ])
  sudo_rule_user_groups = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "user_groups" && members != null)])
  ])

  sudo_rule_hosts = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "hosts" && members != null)])
  ])
  sudo_rule_host_groups = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "host_groups" && members != null)])
  ])

  sudo_rule_commands = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "commands" && members != null)])
  ])
  sudo_rule_command_groups = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "command_groups" && members != null)])
  ])
  sudo_rule_commands_deny = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "commands_deny" && members != null)])
  ])
  sudo_rule_command_groups_deny = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "group" = user } if(user != "all")
    ] if(type == "command_groups_deny" && members != null)])
  ])

  sudo_rule_runasusers = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "runasusers" && members != null)])
  ])
  #sudo_rule_runasuser_groups = flatten([for key, value in var.sudo_rules :
  #  flatten([for type, members in value :
  #    [for user in members : {
  #      "name" = key
  #      "user" = user } if(user != "all")
  #  ] if(type == "runasuser_groups" && members != null)])
  #])
  sudo_rule_runasgroups = flatten([for key, value in var.sudo_rules :
    flatten([for type, members in value :
      [for user in members : {
        "name" = key
        "user" = user } if(user != "all")
    ] if(type == "runasgroups" && members != null)])
  ])
}


##################################################################################
output "sudo_rules" { value = var.sudo_rules }
output "sudo_rule_users" { value = local.sudo_rule_users }
output "sudo_rule_user_groups" { value = local.sudo_rule_user_groups }
output "sudo_rule_hosts" { value = local.sudo_rule_hosts }
output "sudo_rule_host_groups" { value = local.sudo_rule_host_groups }
output "sudo_rule_commands" { value = local.sudo_rule_commands }
output "sudo_rule_command_groups" { value = local.sudo_rule_command_groups }
output "sudo_rule_commands_deny" { value = local.sudo_rule_commands_deny }
output "sudo_rule_command_groups_deny" { value = local.sudo_rule_command_groups_deny }
output "sudo_rule_runasusers" { value = local.sudo_rule_runasusers }
#output "sudo_rule_runasuser_groups" { value = local.sudo_rule_runasuser_groups }
output "sudo_rule_runasgroups" { value = local.sudo_rule_runasgroups }

###################################################################################
resource "freeipa_sudo_rule" "this" {
  for_each = var.sudo_rules

  name               = each.key
  description        = each.value.description
  enabled            = each.value.enabled
  order              = each.value.order
  usercategory       = contains(each.value.users, "all") ? "all" : null
  hostcategory       = contains(each.value.hosts, "all") ? "all" : null
  commandcategory    = contains(each.value.commands, "all") ? "all" : null
  runasusercategory  = contains(each.value.runasusers, "all") ? "all" : null
  runasgroupcategory = contains(each.value.runasgroups, "all") ? "all" : null
}

resource "freeipa_sudo_rule_option" "this" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = var.sudo_rules

  name   = each.key
  option = each.value.sudo_option
}

resource "freeipa_sudo_rule_user_membership" "user" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = { for k, v in local.sudo_rule_users : "${v.name}_-_${v.user}" => v }

  name = each.value.name
  user = each.value.user
}
resource "freeipa_sudo_rule_user_membership" "group" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = { for k, v in local.sudo_rule_user_groups : "${v.name}_-_${v.group}" => v }

  name  = each.value.name
  group = each.value.group
}

resource "freeipa_sudo_rule_host_membership" "hosts" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = { for k, v in local.sudo_rule_hosts : "${v.name}_-_${v.user}" => v }

  name = each.value.name
  host = each.value.user
}
resource "freeipa_sudo_rule_host_membership" "host_groups" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = { for k, v in local.sudo_rule_host_groups : "${v.name}_-_${v.group}" => v }

  name      = each.value.name
  hostgroup = each.value.group
}

resource "freeipa_sudo_rule_allowcmd_membership" "commands" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_commands : "${v.name}_-_${v.user}" => v }

  name    = each.value.name
  sudocmd = each.value.user
}
resource "freeipa_sudo_rule_allowcmd_membership" "command_groups" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_command_groups : "${v.name}_-_${v.group}" => v }

  name          = each.value.name
  sudocmd_group = each.value.group
}
resource "freeipa_sudo_rule_denycmd_membership" "commands" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_commands_deny : "${v.name}_-_${v.user}" => v }

  name    = each.value.name
  sudocmd = each.value.user
}
resource "freeipa_sudo_rule_denycmd_membership" "command_groups" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_command_groups_deny : "${v.name}_-_${v.group}" => v }

  name          = each.value.name
  sudocmd_group = each.value.group
}
resource "freeipa_sudo_rule_runasuser_membership" "runasuser" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_runasusers : "${v.name}_-_${v.group}" => v }

  name      = each.value.name
  runasuser = each.value.user
}
resource "freeipa_sudo_rule_runasgroup_membership" "runasgroup" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each   = { for k, v in local.sudo_rule_runasgroups : "${v.name}_-_${v.group}" => v }

  name       = each.value.name
  runasgroup = each.value.group
}
