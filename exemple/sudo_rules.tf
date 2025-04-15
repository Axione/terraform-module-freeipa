module "rules" {
  ############# DO NOT TOUCH #############
  source = "../../modules/freeipa_policies"
  ########################################

  #description         = optional(string)
  #enabled             = optional(bool, true)
  #order               = optional(number)
  #sudo_option         = optional(string)
  #users               = optional(list(string), [])
  #user_groups         = optional(list(string))
  #hosts               = optional(list(string), [])
  #host_groups         = optional(list(string))
  #commands            = optional(list(string), [])
  #command_groups      = optional(list(string))
  #commands_deny       = optional(list(string), [])
  #command_groups_deny = optional(list(string))
  #runasusers          = optional(list(string), [])
  #runasgroups = optional(list(string), [])
  ########################################

  sudo_rules = {
    allow_all = {
      user_groups = ["devops"]
      hosts       = ["all"]
      commands    = ["all"]
      runasusers  = ["all"]
      runasgroups = ["all"]
    }
  }
}
