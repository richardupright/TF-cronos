# Terraform Cloud w/ Okta
* guide : https://developer.okta.com/blog/2020/02/03/managing-multiple-okta-instances-with-terraform-cloud
* Okta as provider for Terraform : https://www.terraform.io/docs/providers/okta/r/user.html
* Old examples : https://github.com/articulate/terraform-provider-okta-demos/tree/master/terraform


1. Install terraform (guide : https://learn.hashicorp.com/terraform/getting-started/install.html)
	1.1 download the zip, extract the terraform.exe into C:/Program Files/Terraform (only file needed)
	1.2 configure the path (environnement variables > system var > path > add the path to exe file)
2. Terraform Enterprise: Test connection with the okta tenant
	2.1 mkdir okta-user-schema
	2.2 cd okta-user-schema
	2.3 terraform init (does nothing if the rep is empty)
	2.4 create file "okta.auto.tfvars"
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
			token : To generate a new Okta API token, log into your Okta administrator console as a superuser and select API -> Tokens from the navigation menu. Next, click the Create Token button and give your token a name, then click Ok and copy the newly generated token into the configuration file above.
	2.5 create file "identity.tf"
  '
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
  '
	2.6 terraform init
	2.7 terraform plan
	2.8 terraform apply
  2.9 You should see the result in your okta tenant (a custom attributes is added to the profile of okta)
3. Terraform cloud : https://app.terraform.io/signup/account to create an account
	3.1 - create workspace (tf-cronos-prod)
	3.2 - adding github as vcs https://www.terraform.io/docs/cloud/vcs/github.html
		3.2.1 - add new oauth app on github https://github.com/settings/applications/new
		3.2.2 - field values :
    | Application Name           | Terraform Cloud (<YOUR ORGANIZATION NAME>)                                                                      |
|----------------------------|-----------------------------------------------------------------------------------------------------------------|
| Homepage URL               | https://app.terraform.io (or the URL of your Terraform Enterprise instance)                                     |
| Application Description    | Any description of your choice.                                                                                 |
| Authorization callback URL | https://example.com/replace-this-later (or any placeholder; the correct URI doesn't exist until the next step.) |
		3.2.3 - downlaod logo https://www.terraform.io/docs/cloud/vcs/images/tfe_logo-c7548f8d.png
		3.2.4 - set background to #5C4EE5
		3.2.5 - copy client id/ secret
		3.2.6 - on terraform, settings > add vcs > github.com
		3.2.7 - paste the client id/secret
		3.2.8 - copy the url callback
		3.2.9 - on github, update the url callback
		3.2.10 - on terraform, click connect organization
		3.2.11 - authorize user access on github login page
	3.3 - back on the terraform page of the workspace
	3.4 - add terraform variables
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
			make sure to select "sensitive" for the token (it makes it write-only, better security)
	3.5 - add the identity file to the github repo
		3.5.1 - in windows, git clone https://github.com/richardupright/TF-cronos
		3.5.2 - git init
		3.5.3 - git add identity.tf
		3.5.4 - git commit -m ""
		3.5.5 - git push
			use git tortoise for windows to use a graphic interface
	3.6 - Now that you’ve configured your workspace, select Queue plan from the top right, enter a reason, and then press Queue plan.		
4. using terraform for two environnements
	4.1 - create a branch (dev) on the github repo
		4.1.1 - on windows, git checkout -b dev
		4.1.2 - git push origin dev
	4.2 - create new workspace (tf-cronos-dev)
		4.2.1 - select git as vcs, in advanced settings on step 3 specifythe vcs branch as dev
		4.2.2 - in settings of workspace, set for the method apply to auto apply (not manual)
		4.2.3 - with auto apply, every commit on the branch dev will start a terraform plan / apply
	4.3 - promote changes (let the dev team apply the change into the prod environnement)
		4.3.1 - on git, settings > branches > add rule and enter master as the branch pattern to protect
		4.3.2 - apply the Require pull request reviews before merging and Require status checks to pass before merging
		4.3.3 - select dismiss state pull and require review from code owners also
	4.4 - applying changes to the prod environnement
		4.4.1 - on git, open a pull request
		4.4.2 - base master <- compare dev
