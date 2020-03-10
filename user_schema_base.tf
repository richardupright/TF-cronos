###################### /////  USER SCHEMA \\\\\\ ###############################
resource "okta_user_schema" "dob_extension" {
  index      = "date_of_birth"
  title      = "Date of Birth"
  type       = "string"
  master     = "PROFILE_MASTER"
}
resource "okta_user_schema" "crn_extension" {
  index      = "customer_reference_number"
  title      = "Customer Reference Number"
  required   = false
  type       = "string"
  master     = "PROFILE_MASTER"
  depends_on = [okta_user_schema.dob_extension]
}
################################################################################

###################### /////  USER BASE SCHEMA \\\\\\ ##########################
resource "okta_user_base_schema" "firstName" {
  index       = "firstName"
  title       = "First name"
  type        = "string"
  master      = "PROFILE_MASTER"
  permissions = "READ_WRITE"
  required    = true
}
################################################################################
