###################### /////  ENABLE FACTORS \\\\\\ ############################
//https://www.terraform.io/docs/providers/okta/r/factor.html
resource okta_factor google_otp {
  provider_id = "google_otp"
}
resource okta_factor okta_otp {
  provider_id = "okta_otp"
}
resource okta_factor okta_push {
  provider_id = "okta_push"
  depends_on  = [okta_factor.okta_otp ]
}
// resource okta_factor okta_call {
//   provider_id = "okta_call"
// }
// resource okta_factor okta_question {
//   provider_id = "okta_question"
// }
// resource okta_factor okta_sms {
//   provider_id = "okta_sms"
// }
// resource okta_factor fido_u2f {
//   provider_id = "fido_u2f"
// }
// resource okta_factor fido_webauthn{
//   provider_id = "fido_webauthn"
// }
// resource okta_factor rsa_token {
//   provider_id = "rsa_token"
// }
// resource okta_factor symantec_vip {
//   provider_id = "symantec_vip"
// }
// resource okta_factor yubikey_token{
//   provider_id = "yubikey_token"
// }
//  Some providers may require to be manually activated from okta
// rsa and symantec : unsported operation ?
// fido_u2f, fido_webauthn, yubikey_token : need to be enabled by okta support
################################################################################

###################### /////  MFA POLICY \\\\\\ ################################
//https://www.terraform.io/docs/providers/okta/r/policy_mfa.html
resource okta_policy_mfa testmfa {
  name        = "addingMFAfromTerraform"
  status      = "ACTIVE"
  description = "my awesome mfa polciy"

  okta_otp    = {
    enroll    = "REQUIRED"
  }
  okta_push   = {
    enroll    = "OPTIONAL"
  }
  google_otp  = {
    enroll    = "OPTIONAL"
  }
  depends_on  = [
    okta_factor.okta_otp,
    okta_factor.google_otp,
    okta_factor.okta_push,
  ]

  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource okta_policy_rule_mfa mfarulepolicy{
  policyid           = okta_policy_mfa.testmfa.id
  name               = "rule for mfa policy"
  status             = "ACTIVE" //or "INACTIVE".
  enroll             = "LOGIN" //It can be "CHALLENGE", "LOGIN", or "NEVER".
  network_connection = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
################################################################################
