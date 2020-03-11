###################### /////  ADD OAUTH APP \\\\\\ #############################
//https://www.terraform.io/docs/providers/okta/r/app_oauth.html
resource "okta_app_oauth" "f1" {
  label                      = "F1DEMO"
  type                       = "native" //web
  grant_types                = ["authorization_code", "refresh_token", "implicit"]
  redirect_uris              = ["http://localhost:8080/authorization-code/callback","http://localhost:8080/login/oauth2/code/okta"]
  response_types             = ["code", "token", "id_token"]
  login_uri                  = "http://localhost:8080/custom-login"
  issuer_mode                 = "ORG_URL" //CUSTOM_URL
  //client_id = ... to use a custom id
  //tos_uri, logo_uri, policy_uri to specify URI for the client
}

//https://www.terraform.io/docs/providers/okta/d/user.html
data "okta_user" "richard" {
  search {
    name  = "profile.firstName"
    value = "Richard"
  }
  search {
    name  = "profile.lastName"
    value = "Dedecker"
  }
}
// data "okta_user" "richard" {
//   user_id = "00u304rjw6FmijP884x6"
// }

//https://www.terraform.io/docs/providers/okta/r/app_user.html
resource "okta_app_user" "example" {
  app_id   = okta_app_oauth.f1.id
  user_id  = data.okta_user.richard.id
  username = data.okta_user.richard.email
}
################################################################################
