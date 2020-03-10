###################### /////  AUTH SERVER \\\\\\ ###############################
resource "okta_auth_server" "myServer" {
  audiences   = ["api://default"]
  description = "A perfect custom authorization server"
  name        = "custom"
  issuer_mode = "ORG_URL" //custom_url require the definition of a custom domain
  status      = "ACTIVE"
}
################################################################################
