terraform {
  required_providers {
    freeipa = {
      source  = "rework-space-com/freeipa"
      version = "4.3.0"
    }
  }
  backend "s3" {
    bucket                      = "terraform"
    key                         = "freeipa_policies.tfstate"
    region                      = "fr-par"
    endpoints                   = { s3 = "https://s3.fr-par.scw.cloud" }
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "freeipa" {
  host     = "vmname.domain.local"
  username = "admin"
  password = "principal_passwd"
  insecure = true
}
