variable "name" {
  type = string
}

variable "mfa_configuration" {
  type = string
}

variable "password_policy" {
  type = any
}

variable "clients" {
  type = any
}

variable "tags" {
  type = map(string)
}
