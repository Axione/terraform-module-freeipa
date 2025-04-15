module "access" {
  ############# DO NOT TOUCH #############
  source = "../../modules/freeipa_policies"
  ########################################

  hbac_policy = {
    devops_allow_all = {
      description = "Allow devops users to access any host from any host"
      user_groups = ["devops"]
      hosts       = ["all"]
      services    = ["all"]
    }
  }
}

