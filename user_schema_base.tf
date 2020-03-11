###################### /////  USER SCHEMA \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/user_schema.html
resource okta_user_schema dob_extension {
  index      = "date_of_birth"
  title      = "Date of Birth"
  type       = "string" //boolean, number, integer, array, object
  master     = "PROFILE_MASTER"  //or "OKTA"
  description = "The date of birth for that user"
}
resource okta_user_schema crn_extension {
  index      = "customer_reference_number"
  title      = "Customer Reference Number"
  required   = false
  type       = "string"
  master     = "PROFILE_MASTER"
  max_length = 10 //only for string
  min_length = 1
  depends_on = [okta_user_schema.dob_extension]
}
################################################################################

###################### /////  USER BASE SCHEMA \\\\\\ ##########################
//https://www.terraform.io/docs/providers/okta/r/user_base_schema.html
resource okta_user_base_schema firstName {
  index       = "firstName"
  title       = "First name"
  type        = "string"
  master      = "PROFILE_MASTER"
  permissions = "READ_WRITE"
  required    = true
}
################################################################################
