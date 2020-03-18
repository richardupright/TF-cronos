<img style="float: left;" src="hashicorp-terraform-logo.png" alt="Terraform logo" width="193" height="193">

# Terraform Cloud w/ Okta

\
\
\
\
Terraform is an orchestration tool that uses declarative code to build, change and version infrastructure that is made up of server instances and services. You can use Okta's official Terraform provider to interact with Okta services. Existing Okta infrastructure can be imported and brought under Terraform management.

Terraform comes in 2 solutions : on-prem or cloud.
* on-prem is free, no restriction.
* cloud is free with a limit of 5 users in the team.\
You can also have Terraform Enterprise, which is the cloud solution without restrictions but isn't free.
Terraform [pricings](https://www.hashicorp.com/products/terraform/pricing/)

## Terraform on-prem (CLI)
See this [guide](https://learn.hashicorp.com/terraform/getting-started/install.html) for more informations.
1. Install terraform
	*  download the zip, extract the *terraform.exe* into *C:/Program Files/Terraform* (only file needed)
	*  Add the exe path to the env. variables (environment variables > system var > path > add the path to exe file)
2. Test connection with Okta
Create a directory, and in there create a file that Terraform will use later to apply configuration to Okta.
	*  mkdir okta-user-schema (this will be the directory)
	*  cd okta-user-schema
	*  terraform init
		* Used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control.
	*  create the file "okta.auto.tfvars"\
This file will be used later by the conf files (a .tf file) to use the Okta provider.
	```
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
	```
	For all files which match terraform.tfvars or .auto.tfvars present in the current directory, Terraform automatically loads them to populate variables. If the file is named something else, you can use the -var-file flag directly to specify a file.\
	**DO NOT PUSH THOSE FILES TO A VCS** : you don't want your api token to be public, and your vcs will be public.
	* To generate a new Okta API token, log into your Okta administrator console as a superuser and select API -> Tokens from the navigation menu. Next, click the Create Token button and give your token a name, then click Ok and copy the newly generated token into the configuration file above.
	*  create the file *identity .tf*
	This is the conf file that will specify which provider to use (Okta), and then add a custom attributes to the user schema.
  The name of the file does not matter, Terraform will go through every .tf files located in the directory.

	```
		variable "org_name" {}
		variable "api_token" {}
		variable "base_url" {}

		provider "okta" {
			org_name = var.org_name
			base_url = var.base_url
			api_token = var.api_token
		}
		resource "okta_user_schema" "dob_extension" {
			index  = "date_of_birth"
			title  = "Date of Birth"
			type   = "string"
			master = "PROFILE_MASTER"
		}
	```
  When Terraform reads this file, he sees the variables declared but not initialized (no attributes are configured) so it will look for a .tfvars file to fill any variables it can.
	* terraform init //you can execute the command as much as you want
	* terraform plan
		* In this step, Terraform will make a comparison between the state and the resources created in the .tf files : the state refers to what Terraform knows from an environment (it's configuration). This means that Terraform will check what resources need to be created/updated/deleted.
	* terraform apply
		* Terraform performs the changes it established in the plan step.
	* You should see the result in your Okta tenant (a custom attributes is added to the user profile of okta)

## Terraform Cloud
1. Terraform cloud : [Create an account](https://app.terraform.io/signup/account)
	* Create workspace (tf-cronos-prod)
		* Workspaces describe your environments (production, staging, development, etc.).
	* [Adding GitHub as vcs](https://www.terraform.io/docs/cloud/vcs/github.html)
		* [add new OAuth app on GitHub](https://github.com/settings/applications/new)
		* field values :
			* Application Name  =  Terraform Cloud ("YOUR ORGANIZATION NAME")                          
			* Homepage URL  = https://app.terraform.io (or the URL of your Terraform Enterprise instance)     
			* Application Description  = Any description of your choice.                                                      	|
			* Authorization callback URL =https://abc.com/(or any placeholder, correct URI doesn't exist until the next step.)
		* [download logo](https://www.terraform.io/docs/cloud/vcs/images/tfe_logo-c7548f8d.png)
		* set background to #5C4EE5
		* copy client id/ secret
		* on terraform, settings > add vcs > github.com
		* paste the client id/secret
		* copy the URL callback
		* on GitHub, update the URL callback
		* on terraform, click *connect organization*
		* authorize user access on GitHub login page
	* back on the terraform page of the workspace
	* add terraform variables
	```
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
	```
		* This removes the need to use a .tfvars file : that means you don't need to have a .tfvars on github (for security) because Terraform will look into the variables configured in the cloud (the variables are declared for one workspace)
	* make sure to select "sensitive" for the token (it makes it write-only, better security)
	* add the identity file to the GitHub repo
		* in windows, git clone https://github.com/richardupright/TF-cronos
		* git init
		* git add identity.tf
		* git commit -m ""
		* git push
		*use git tortoise for windows to use a graphic interface*
	* Now that you’ve configured your workspace, select Queue plan from the top right, enter a reason, and then press Queue plan.\
	While we had to execute the terraform commands with the CLI solution (plan and apply), the cloud solution works differently : once the files are pushed to the VCS, you must *queue* a plan, which will make terraform execute itself the commands *plan* and *apply*. 	
2. using terraform for two environments\
Before going further, make sure you have admin access to 2 Okta environments.\
One workspace on Terraform "corresponds" to an Okta environment : a workspace (TF-cronos-prod) is connected to the Okta environment that is already configured, another workspace (TF-cronos-dev) is connected to the Okta environment that is not yet configured.
You will use only one git rep with two different branches corresponding to the Okta tenants.
For easy configuration, branch *master* will be connected to the workspace TF-cronos-prod,
and the branch *dev* to the workspace TF-cronos-dev
	* create a branch (dev) on the GitHub repo
		* on windows, git checkout -b dev
		* git push origin dev
	* create new workspace (tf-cronos-dev)
		* select git as vcs, in advanced settings on step 3 specify the vcs branch as dev
			* if this is not specified, Terraform will use the master branch to check for configuration files.
		* in settings of the workspace, set for the method apply to auto apply (not manual)
			* with auto apply, every commit on the branch dev will start a terraform plan / apply (a queue)
	* When you want to apply the change you made in the dev branch into the prod branch, you have to configure the branch to be *protected*
		* on git, settings > branches > add rule and enter master as the branch pattern to protect
		* apply the Require pull request reviews before merging and Require status checks to pass before merging
		* select *dismiss state pull* and *require review from code owners* also
	* applying changes to the prod environment
		* on git, open a pull request
		* base master <- compare dev


# Terraform : brief documentation
## Providers
Terraform is used to create, manage, and update infrastructure resources such as physical machines, VMs, network switches, containers, and more.
A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS, PaaS, or SaaS services.
### Okta Provider
The Okta provider is used to interact with the resources supported by Okta. The provider needs to be configured with the proper credentials before it can be used : the org name, the base url and the api token.\
[Okta Provider Documentation](https://www.terraform.io/docs/providers/okta/index.html)
#### Data sources
Data sources refer to the resources retrievable from an Okta environment.\
List of all resources available for the moment :
* App_metadata_saml
* App_saml
* App
* Auth_server
* Auth_server_policy
* Default_policy
* Everyone_group
* Group
* IDP_metadata_saml
* IDP_saml
* Policy
* User_profile_mapping_source
* User
* Users

#### Resources
Resources refer to the resources creatable on an Okta environment.
* app_auto_login
* app_bookmark
* app_basic_auth
* app_auto_login
* app_bookmark
* app_basic_auth
* app_group_assignment
* app_oauth
* app_saml
* app_secure_password_store
* app_swa
* app_three_field
* app_user_base_schema
* app_user_schema
* app_user
* auth_server_claim
* auth_server_policy_rule
* auth_server_policy
* auth_server_scope
* auth_server
* factor
* group_roles
* group_rule
* group
* idp_oidc
* idp_saml_signing_key
* idp_saml
* idp_social
* inline_hook
* network_zone
* policy_mfa
* policy_password
* policy_rule_idp_discovery
* policy_rule_mfa
* policy_rule_password
* policy_rule_signon
* policy_signon
* template_email
* trusted_origin
* user_base_schema
* user_schema
* user
* profile_mapping

#### Limitations of the Okta provider
This is a list of options the Okta provider does not offer yet (as of march 2020). The provider use the Okta API.
* Active directory
* Customization Settings, except template email
* User Mappings
* API	integrations on preconfigured applications, such as AWS SAML App.
* SAML Roles on AWS SAML App
* Hooking up inline token hooks (they can be created and managed but not flipped on)

## State
Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

This state is stored by default in a local file named *terraform.tfstate*, but it can also be stored remotely, which works better in a team environment.

Terraform uses this local state to create plans and make changes to your infrastructure. Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.

While the format of the state files are just JSON, direct file editing of the state is discouraged. Terraform provides the terraform state command to perform basic modifications of the state using the CLI.

## Import
Terraform is able to import existing infrastructure. This allows you take resources you've created by some other means and bring it under Terraform management.\
The current implementation of Terraform import can only import resources into the state. It does not generate configuration. A future version of Terraform will also generate configuration.
Because of this, prior to running terraform import it is necessary to write manually a resource configuration block for the resource, to which the imported object will be mapped.\
While this may seem tedious, it still gives Terraform users an avenue for importing existing resources. A future version of Terraform will fully generate configuration, significantly simplifying this process.

### How to import
The terraform import command is used to import existing infrastructure.

The command currently can only import one resource at a time. This means you can't yet point Terraform import to an entire collection of resources such as an AWS VPC and import all of it. This workflow will be improved in a future version of Terraform.

To import a resource, first write a resource block for it in your configuration, establishing the name by which it will be known to Terraform:
```
	resource okta_user example {}
```
If desired, you can leave the body of the resource block blank for now and return to fill it in once the instance is imported.

Now terraform import can be run to attach an existing instance to this resource configuration:
```
	terraform import okta_user.example 00u26rcjhNGYPMsQU4x6
```
This command locates the Okta user with ID 00u26rcjhNGYPMsQU4x6. Then it attaches the existing settings of the user, as described by the Okta API, to the name okta_user.example of a module. Finally, the mapping is saved in the Terraform state.

As a result of the above command, the resource is recorded in the state file.



# Rockstar chrome browser extension
[link to download](https://chrome.google.com/webstore/detail/rockstar/chjepkekmhealpjipcggnfepkkfeimbd)

Enhance Okta with these features:

* Export Objects to CSV :
	* Users
	* Groups
	* Group Members
	* Group Rules
	* Directory Users
	* Apps
	* App Users
	* App Groups
	* App Notes
	* Network Zones
	* YubiKeys
	* Mappings
	* Admins
* User home page: Show SSO (SAML assertion...)
* People page: enhanced search
* Person page: show login/email and AD info, show user detail, enhance menus/title, manage user's admin roles, verify factors
* Groups page: search using regular expressions (like wildcards)
* Action Directory page: show OU tooltips, export OUs
* Identity Providers page: show SAML certificate expiration date
* Events: Expand All and Expand Each Row
* API: API Explorer, Pretty Print JSON

Note: This extension was not created by Okta. It is not supported by Okta. It is an unofficial extension created by the community.

## Atom

Configure Atom for easier use of GitHub
  * Download [here](https://atom.io/)
  * plugins to install :
    * https://atom.io/packages/git-plus
    * https://atom.io/packages/language-hcl
    * https://atom.io/packages/atom-beautify
  * [Configure github with SSH](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

	## Links to documentation
	Useful documentation :
	* [Terraform docs](https://www.terraform.io/docs/providers/okta/index.html)
	* [Terraform examples](https://github.com/articulate/terraform-provider-okta/tree/master/examples)
	* [Source code of the Okta API](https://github.com/articulate/terraform-provider-okta/tree/master/okta)
	* [guide](https://developer.okta.com/blog/2020/02/03/managing-multiple-okta-instances-with-terraform-cloud)
	* [Okta as provider for Terraform](https://www.terraform.io/docs/providers/okta/r/user.html)
	* [Old examples](https://github.com/articulate/terraform-provider-okta-demos/tree/master/terraform)
