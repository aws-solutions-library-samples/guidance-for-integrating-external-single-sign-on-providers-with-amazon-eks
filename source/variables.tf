variable "admin_user_config" {
  description = "Configuration for Platform Admin Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "Zilberman"
    first_name = "Daniel"
    email      = "dan@example.com"
  }]
}

variable "user_config" {
  description = "Configuration for Developer Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "Joseph"
    first_name = "Judith"
    email      = "celijose@amazon.com"
    },
    {
      last_name  = "Velagala"
      first_name = "Sreedevi"
      email      = "velagasr@amazon.com"
    }
  ]
}
