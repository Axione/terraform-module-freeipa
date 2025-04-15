module "groups" {
  ############# DO NOT TOUCH #############
  source = "../../modules/freeipa_policies"
  ########################################

  # Profile groups
  groups = {
    devops = { description = "Devops group" }
    dev    = { description = "Developers group" }
    ro     = { description = "Readonly group" }
  }
  groups_membership = {
    devops = { user = ["toto", "titi"] }
    #readonly = { user = ["toto"]}
    #test = { group = ["titi"], user = ["toto"]}
  }

}

