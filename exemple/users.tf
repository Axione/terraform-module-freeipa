module "users" {
  ############# DO NOT TOUCH #############
  source = "../../modules/freeipa_policies"
  #######################################

  users = {
    "toto" = {
      first_name    = "toto"
      last_name     = "tt"
      email_address = ["toto@exemple.fr"]
    }
    "titi" = {
      first_name     = "titi"
      last_name      = "ii"
      email_address  = ["titi@exemple.fr"]
      ssh_public_key = ["ssh-ed25519 xxxxxxxxxxxxxxxxxxxxxxxxx"]
    }
  }
}
