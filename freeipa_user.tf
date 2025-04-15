##################################################################################
variable "users" {
  type = map(object({
    first_name               = string
    last_name                = string
    account_disabled         = optional(bool)
    car_license              = optional(list(string))
    city                     = optional(string)
    display_name             = optional(string)
    email_address            = optional(list(string))
    employee_number          = optional(string)
    employee_type            = optional(string)
    full_name                = optional(string)
    gecos                    = optional(string)
    gid_number               = optional(number)
    home_directory           = optional(string)
    initials                 = optional(string)
    job_title                = optional(string)
    krb_password_expiration  = optional(string)
    krb_principal_expiration = optional(string)
    krb_principal_name       = optional(list(string))
    login_shell              = optional(string)
    manager                  = optional(string)
    mobile_numbers           = optional(list(string))
    organisation_unit        = optional(string)
    postal_code              = optional(string)
    preferred_language       = optional(string)
    province                 = optional(string)
    random_password          = optional(bool)
    ssh_public_key           = optional(list(string))
    street_address           = optional(string)
    telephone_numbers        = optional(list(string))
    uid_number               = optional(number)
    userclass                = optional(list(string))
    userpassword             = optional(string)
  }))
  default = {}
}


##################################################################################
resource "freeipa_user" "this" {
  for_each = var.users

  name                     = each.key
  first_name               = each.value.first_name
  last_name                = each.value.last_name
  account_disabled         = each.value.account_disabled
  car_license              = each.value.car_license
  city                     = each.value.city
  display_name             = each.value.display_name
  email_address            = each.value.email_address
  employee_number          = each.value.employee_number
  employee_type            = each.value.employee_type
  full_name                = each.value.full_name
  gecos                    = each.value.gecos
  gid_number               = each.value.gid_number
  home_directory           = each.value.home_directory
  initials                 = each.value.initials
  job_title                = each.value.job_title
  krb_password_expiration  = each.value.krb_password_expiration
  krb_principal_expiration = each.value.krb_principal_expiration
  krb_principal_name       = each.value.krb_principal_name
  login_shell              = each.value.login_shell
  manager                  = each.value.manager
  mobile_numbers           = each.value.mobile_numbers
  organisation_unit        = each.value.organisation_unit
  postal_code              = each.value.postal_code
  preferred_language       = each.value.preferred_language
  province                 = each.value.province
  random_password          = each.value.random_password
  ssh_public_key           = each.value.ssh_public_key
  street_address           = each.value.street_address
  telephone_numbers        = each.value.telephone_numbers
  uid_number               = each.value.uid_number
  userclass                = each.value.userclass
  userpassword             = each.value.userpassword
}
