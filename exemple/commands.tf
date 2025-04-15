module "commands" {
  ############# DO NOT TOUCH #############
  source = "../../modules/freeipa_policies"
  ########################################

  #List of all allowed sudo commands
  sudo_cmd = [
    "/bin/bash",
    "/bin/cat",
    "/usr/bin/less",
    "/usr/bin/vim",
    "/bin/which",
    "/usr/bin/docker ps -a",
    "/usr/bin/docker",
  ]

  # Group sudo commands to easily affect them to user profile
  sudo_cmd_group = {
    terminals = {
      description = "The terminals allowed to be sudoed"
      commands    = ["/bin/bash", "/bin/fish"]
    }
    docker_full = {
      description = "The Docker commands allowed"
      commands    = ["/usr/bin/docker"]
    }
    docker_read = {
      description = "The Docker commands allowed"
      commands    = ["/usr/bin/docker ps -a", ]
    }
  }
}

