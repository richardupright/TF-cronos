###################### /////  ADD OAUTH APP \\\\\\ #############################
resource "okta_app_oauth" "f1" {
  label                      = "F1DEMO"
  type                       = "native" //web
  grant_types                = ["authorization_code", "refresh_token", "implicit"]
  redirect_uris              = ["http://localhost:8080/authorization-code/callback","http://localhost:8080/login/oauth2/code/okta"]
  response_types             = ["code", "token", "id_token"]
  login_uri                  = "http://localhost:8080/custom-login"
  issuer_mode                 = "ORG_URL" //CUSTOM_URL
}
################################################################################
