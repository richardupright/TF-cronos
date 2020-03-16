# Terraform Cloud w/ Okta
* guide : https://developer.okta.com/blog/2020/02/03/managing-multiple-okta-instances-with-terraform-cloud
* Okta as provider for Terraform : https://www.terraform.io/docs/providers/okta/r/user.html
* Old examples : https://github.com/articulate/terraform-provider-okta-demos/tree/master/terraform

Terraform is an orchestration tool that uses declarative code to build, change and version infrastructure that is made up of server instances and services. You can use Okta's official Terraform provider to interact with Okta services. Existing Okta infrastructure can be imported and brought under Terraform management. 

1. Install terraform (guide : https://learn.hashicorp.com/terraform/getting-started/install.html)
	*  download the zip, extract the *terraform.ex*e into *C:/Program Files/Terraform* (only file needed)
	*  configure the path (environnement variables > system var > path > add the path to exe file)
2. Terraform Enterprise: Test connection with the okta tenant
	*  mkdir okta-user-schema
	*  cd okta-user-schema
	*  terraform init (does nothing if the rep is empty)
	*  create the file "okta.auto.tfvars"
	```
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
	```
	* To generate a new Okta API token, log into your Okta administrator console as a superuser and select API -> Tokens from the navigation menu. Next, click the Create Token button and give your token a name, then click Ok and copy the newly generated token into the configuration file above.
	*  create the file *identity .tf*
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

	* terraform init
	* terraform plan
	* terraform apply
	* You should see the result in your okta tenant (a custom attributes is added to the profile of okta)
3. Terraform cloud : https://app.terraform.io/signup/account to create an account
	* Create workspace (tf-cronos-prod)
	* Adding github as vcs https://www.terraform.io/docs/cloud/vcs/github.html
		* add new oauth app on github https://github.com/settings/applications/new
		* field values :
			* Application Name  =  Terraform Cloud ("YOUR ORGANIZATION NAME")                          
			* Homepage URL  = https://app.terraform.io (or the URL of your Terraform Enterprise instance)     
			* Application Description  = Any description of your choice.                                                      	|
			* Authorization callback URL =https://abc.com/(or any placeholder, correct URI doesn't exist until the next step.)
		* downlaod logo https://www.terraform.io/docs/cloud/vcs/images/tfe_logo-c7548f8d.png
		* set background to #5C4EE5
		* copy client id/ secret
		* on terraform, settings > add vcs > github.com
		* paste the client id/secret
		* copy the url callback
		* on github, update the url callback
		* on terraform, click connect organization
		* authorize user access on github login page
	* back on the terraform page of the workspace
	* add terraform variables
	```
		org_name  = "dev-1234"
		base_url  = "okta.com"
		api_token = "<your-api-token>"
	```
	* make sure to select "sensitive" for the token (it makes it write-only, better security)
	* add the identity file to the github repo
		* in windows, git clone https://github.com/richardupright/TF-cronos
		* git init
		* git add identity.tf
		* git commit -m ""
		* git push
		*	use git tortoise for windows to use a graphic interface
	* Now that you’ve configured your workspace, select Queue plan from the top right, enter a reason, and then press Queue plan.		
4. using terraform for two environnements
	* create a branch (dev) on the github repo
		* on windows, git checkout -b dev
		* git push origin dev
	* create new workspace (tf-cronos-dev)
		* select git as vcs, in advanced settings on step 3 specifythe vcs branch as dev
		* in settings of workspace, set for the method apply to auto apply (not manual)
		* with auto apply, every commit on the branch dev will start a terraform plan / apply
	* promote changes (let the dev team apply the change into the prod environnement)
		* on git, settings > branches > add rule and enter master as the branch pattern to protect
		* apply the Require pull request reviews before merging and Require status checks to pass before merging
		* select dismiss state pull and require review from code owners also
	* applying changes to the prod environnement
		* on git, open a pull request
		* base master <- compare dev
5. Configure Atom for easier use of github
    * Download here : https://atom.io/
    * plugins to install :
      * https://atom.io/packages/git-plus
      * https://atom.io/packages/language-hcl
      * https://atom.io/packages/atom-beautify
    * Configure github with SSH : https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
6. Links to documentation
	* [Terraform docs](https://www.terraform.io/docs/providers/okta/index.html)
	* [Terraform examples](https://github.com/articulate/terraform-provider-okta/tree/master/examples)
	* [Source code of the Okta API](https://github.com/articulate/terraform-provider-okta/tree/master/okta)
7. Limitations
	* Customization Settings, exept template email
	* User Mappings
	* API	integrations on preconfigured applications, such as AWS SAML App.
	* SAML Roles on AWS SAML App
	* Hooking up inline token hooks (they can be created and managed but not flipped on)
