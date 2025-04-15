# Freeipa users and policies management



## How to use this module



#### Create a providers.tf file

```
terraform {
  required_providers {
    freeipa = {
      source  = "rework-space-com/freeipa"
      version = "5.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.9.0"
    }
  }
  backend "s3" {
    bucket                      = "terraform-states"
    key                         = "freeipa_policies.tfstate"
    region                      = "fr-par"
    endpoints                   = { s3 = "https://s3.fr-par.scw.cloud" }
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "freeipa" {
  host     = "hostname-ldap.example.com"
  username = "admin"
  password  = data.vault_generic_secret.freeipa.data["ipaadmin_password"]
  insecure = true
```



## Presentation

There is a separated file for each group of variable

- users.tf : users creation
- groups.tf: Groups and users assignment creation
- commands.tf: list of commands and commands group creation
- access.tf: list of vms access
- sudo_rules.tf: list of rights inside the vm

## users.tf

```
  users = {
    "user_ssh_name" = {
      first_name    = "prenom"
      last_name     = "nom"
      email_address = ["email@exemple.fr"]
    }
```

No matter the password you set, the user will need to set a new one that only known by him.

Optionnaly you can add this variables:

    account_disabled         = optional(bool)
    car_license              = optional(list(string))
    city                     = optional(string)
    display_name             = optional(string)
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

## groups.tf

There is 2 variables here

- groups = {} > declare the groups
- groups_membership = {} : Assign user or others group inside an existing group 


example: 

```
  groups = {} > declare the groups
    devops = { description = "Devops group" }
    dev    = { description = "Developers group" }
    ro     = { description = "Readonly group" }
  }

  groups_membership = {
    devops = { user = ["tttttt", "aaaa"] }
    readonly = { user = ["toto"]}
    test = { group = ["titi"], user = ["toto"]}
  }
```




## commands.tf


## access.tf

## sudo_rules.tf
