# Defining variable here to use if after, but they are initialized on Terraform (in environnment variables)
variable "org_name" {}
variable "api_token" {}
variable "base_url" {}
variable domain {
    default     = "example.com"
}
// variable enable_group_rule {
//     default     = true
// }
