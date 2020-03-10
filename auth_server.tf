###################### /////  AUTH SERVER \\\\\\ ###############################
resource okta_auth_server myServer {
  audiences   = ["api://default"]
  description = "A perfect custom authorization server"
  name        = "custom"
  issuer_mode = "ORG_URL" //custom_url require the definition of a custom domain
  status      = "ACTIVE"
  //audiences = ...
}

resource okta_auth_server_claim test {
  name           = "claimssss"
  status         = "ACTIVE"
  claim_type     = "RESOURCE"
  value_type     = "EXPRESSION"
  value          = "cool_updated"
  auth_server_id = okta_auth_server.myServer.id
  //scopes = [] list of scopes the claim is tied to
}

resource "okta_auth_server_policy" "test" {
  status           = "ACTIVE"
  name             = "policyformyauthserver"
  description      = "test "
  priority         = 1
  client_whitelist = ["ALL_CLIENTS"]
  auth_server_id   = okta_auth_server.myServer.id
}
resource "okta_auth_server_policy_rule" "test" {
  auth_server_id       = okta_auth_server.myServer.id
  policy_id            = okta_auth_server_policy.test.id
  status               = "ACTIVE"
  name                 = "testing"
  priority             = 1
  group_whitelist      = ["${data.okta_group.all.id}"]
  grant_type_whitelist = ["password"]
}
resource "okta_auth_server_scope" "test" {
  consent        = "REQUIRED"
  description    = "test_updated"
  name           = "testsomething"
  auth_server_id = "${okta_auth_server.myServer.id}"
}
################################################################################
