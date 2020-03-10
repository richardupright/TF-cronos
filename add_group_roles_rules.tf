###################### /////  ADDING GROUP \\\\\\ ##############################
resource "okta_group" "awesomeGroup" {
  name        = "awesome"
  description = "My Awesome Group"
}
################################################################################

###################### /////  GROUP ROLES \\\\\\ ###############################
// resource "okta_group_roles" "awesomeGroupRoles" {
//   group_id    = "${okta_group.awesomeGroup.id}" //deprecated style (0.11)
//   group_id    = "okta_group.awesomeGroup.id" //0.12 style
//   admin_roles = ["SUPER_ADMIN"]
// }
################################################################################

###################### /////  GROUP RULES \\\\\\ ###############################
//group membership rules cannot be created for groups with administrators roles
resource "okta_group_rule" "addingUserRule" {
  count             = var.enable_group_rule ? 1 : 0 // Do not create if group rule feature is not available
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = ["${okta_group.awesomeGroup.id}"]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
//expression_value  = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
################################################################################
