##################################################################################
variable "sudo_rules" {
  type = map(object({
    description         = optional(string)
    enabled             = optional(bool, true)
    order               = optional(number)
    sudo_option         = optional(string, "!authenticate")
    users               = optional(list(string))
    user_groups         = optional(list(string))
    hosts               = optional(list(string))
    host_groups         = optional(list(string))
    commands            = optional(list(string))
    command_groups      = optional(list(string))
    commands_deny       = optional(list(string))
    command_groups_deny = optional(list(string))
    runasusers          = optional(list(string))
    runasgroups         = optional(list(string))
  }))
  default = {}
}

###################################################################################
resource "freeipa_sudo_rule" "this" {
  for_each = var.sudo_rules

  name               = each.key
  description        = each.value.description
  enabled            = each.value.enabled
  order              = each.value.order
	usercategory = try(
	  contains(each.value.users, "all") ? "all" : null,
	  null
	)
	hostcategory = try(
	  contains(each.value.hosts, "all") ? "all" : null,
	  null
	)
	commandcategory = try(
	  contains(each.value.commands, "all") ? "all" : null,
	  null
	)
	runasusercategory = try(
	  contains(each.value.runasusers, "all") ? "all" : null,
	  null
	)
	runasgroupcategory = try(
	  contains(each.value.runasgroups, "all") ? "all" : null,
	  null
	)
}

resource "freeipa_sudo_rule_option" "this" {
  depends_on = [freeipa_sudo_rule.this]
  for_each   = var.sudo_rules

  name   = each.key
  option = each.value.sudo_option
}

resource "freeipa_sudo_rule_user_membership" "this" {
  depends_on = [freeipa_sudo_rule.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.users != null ? (length(value.users) == 1 && value.users[0] == "all") : true) || 
    value.user_groups != null 
  }

  name   = each.key
  users  = each.value.users
  groups = each.value.user_groups
}

resource "freeipa_sudo_rule_host_membership" "this" {
  depends_on = [freeipa_sudo_rule.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.hosts != null ? (length(value.hosts) == 1 && value.hosts[0] == "all") : true) || 
    value.host_groups != null 
  }

  name   = each.key
  hosts = each.value.hosts
  hostgroups = each.value.host_groups
}

resource "freeipa_sudo_rule_allowcmd_membership" "this" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.commands != null ? (length(value.commands) == 1 && value.commands[0] == "all") : true) ||
    value.command_groups != null
  }

  name   = each.key
  sudocmds = each.value.commands
  sudocmd_groups = each.value.command_groups
}

resource "freeipa_sudo_rule_denycmd_membership" "this" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.commands != null ? (length(value.commands) == 1 && value.commands[0] == "all") : true) ||
		value.commands_deny != null || value.command_groups_deny != null
  }

  name   = each.key
  sudocmds = each.value.commands_deny
  sudocmd_groups = each.value.command_groups_deny
}

resource "freeipa_sudo_rule_runasuser_membership" "this" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.runasusers != null ? (length(value.runasusers) == 1 && value.runasusers[0] == "all") : true)
  }

  name   = each.key
  runasusers = each.value.runasusers
}

resource "freeipa_sudo_rule_runasgroup_membership" "this" {
  depends_on = [freeipa_sudo_rule.this, freeipa_sudo_cmdgroup_membership.this]
  for_each = {
    for key, value in var.sudo_rules : key => value
		if !(value.runasgroups != null ? (length(value.runasgroups) == 1 && value.runasgroups[0] == "all") : true)
  }

  name   = each.key
  runasgroups = each.value.runasgroups
}
