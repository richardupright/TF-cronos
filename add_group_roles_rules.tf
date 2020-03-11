###################### /////  ADDING GROUP \\\\\\ ##############################
//https://www.terraform.io/docs/providers/okta/r/group.html
resource "okta_group" "awesomeGroup" {
  name        = "awesome"
  description = "My Awesome Group"
}
resource okta_group uselessGroup {
  name        = "useless"
  description = "Group for admin"
}
################################################################################

###################### /////  GROUP ROLES \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/group_roles.html
resource "okta_group_roles" "awesomeGroupRoles" {
  group_id    = okta_group.uselessGroup.id
  admin_roles = ["SUPER_ADMIN"]
  //values are : "SUPER_ADMIN", "ORG_ADMIN", "APP_ADMIN", "USER_ADMIN", "HELP_DESK_ADMIN",
  //"READ_ONLY_ADMIN", "MOBILE_ADMIN", "API_ACCESS_MANAGEMENT_ADMIN", "REPORT_ADMIN".
}
################################################################################

###################### /////  GROUP RULES \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/group_rule.html
//group membership rules cannot be created for groups with administrators roles
resource "okta_group_rule" "addingUserRule" {
  count             = var.enable_group_rule ? 1 : 0 // Do not create if group rule feature is not available
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = [okta_group.awesomeGroup.id]
  expression_type   = "urn:okta:expression:1.0" //expression type to use to invoke the rule
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
  // = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
################################################################################
