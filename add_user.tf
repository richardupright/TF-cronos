###################### /////  ADDING USER \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/user.html
resource "okta_user" "example" {
  count 	    = 4 //creates four new users (0,1,2,3)
  email 	    = "TerraformUser${count.index}@terraform.be"
  login 	    = "TerraformUser${count.index}@terraform.be"
  first_name  = "terraUser ${count.index}"
  last_name   = "form"
}
//can't specify custom attribute

resource "okta_user" "addingJESUS" {
  email 	    = "jesus@terraform.be"
  login 	    = "jesus@terraform.be"
  first_name  = "Jesus"
  last_name   = "Christ"
  admin_roles = ["SUPER_ADMIN"]
  zip_code = "1234"
  title = "employe of Terraform"
  primary_phone = "+320485963258"
}

resource "okta_user" "addingUserWithID" {
  id          = "00g26qaa4IMw25M2a4x6"
  email 	    = "t@terraform.be"
  login 	    = "t@terraform.be"
  first_name  = "Test"
  last_name   = "Test"
}
################################################################################
