##################################################################################
variable "hbac_policy" {
  type = map(object({
    description    = optional(string)
    enabled        = optional(bool, true)
    users          = optional(list(string))
    user_groups    = optional(list(string))
    hosts          = optional(list(string))
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
	usercategory = try(
	  contains(each.value.users, "all") ? "all" : null,
	  null
	)
	hostcategory = try(
	  contains(each.value.hosts, "all") ? "all" : null,
	  null
	)
	servicecategory = try(
	  contains(each.value.services, "all") ? "all" : null,
	  null
	)
}

resource "freeipa_hbac_policy_user_membership" "this" {
  depends_on = [freeipa_hbac_policy.this]
  for_each = {
    for key, value in var.hbac_policy : key => value
		if !(value.users != null ? (length(value.users) == 1 && value.users[0] == "all") : true) || 
    value.user_groups != null 
  }

  name = each.key
  users = each.value.users
  groups = each.value.user_groups
}

resource "freeipa_hbac_policy_host_membership" "this" {
  depends_on = [freeipa_hbac_policy.this]
	for_each = {
    for key, value in var.hbac_policy : key => value
		if !(value.hosts != null ? (length(value.hosts) == 1 && value.hosts[0] == "all") : true) || 
    value.host_groups != null 
  }

  name = each.key
  hosts = each.value.hosts
  hostgroups = each.value.host_groups
}

resource "freeipa_hbac_policy_service_membership" "services" {
  depends_on = [freeipa_hbac_policy.this]
	for_each = {
    for key, value in var.hbac_policy : key => value
		if !(value.services != null ? (length(value.services) == 1 && value.services[0] == "all") : true) || 
    value.service_groups != null 
  }

  name    = each.key
  services = each.value.services
  servicegroups = each.value.service_groups
}
