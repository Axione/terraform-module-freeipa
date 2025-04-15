#output "user_group_membership" { value = module.freeipa_groups.user_group_membership }
#output "user_user_group_membership" { value = module.freeipa_groups.user_user_group_membership }
#output "group_user_group_membership" { value = module.freeipa_groups.group_user_group_membership }
#output "ship" { value = module.freeipa_groups.test }
#output "flatten_sudo_cmd_group" { value = module.freeipa_cmd.flatten_sudo_cmd_group }
#output "sudo_cmd_list" { value = module.freeipa_cmd.sudo_cmd_list }
#output "user_hbac_policy" { value = module.acces.hbac_policy_users }
#output "hbac_policy_svcgrp" { value = module.acces.hbac_policy_service_groups }

