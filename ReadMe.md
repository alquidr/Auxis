# DEVOPS TECHNICAL TEST

## INTRODUCTION

This is the solution for the Auxis devops technical test. 
The main goal, is to configure a load balancer, and receive requests from outside, 
and return an html from a ec2 ngnix instance.

The project contains the next files:
    Terraform file: _main.tf_
    Instructions file: _ReadMe.md_
    CookBook folder: _cookbooks folder_


### CONSIDERATIONS

I decided to use an AWS ELB feature instead of an ec2 to simplify the architecture, and reduce de costs.

### CHEF CONFIGURATION

To configure the chef server, you must follow the next steps:
1. Create a chef account in the site _https://manage.chef.io_ 
2. Create a new organization inside this called _qrvey-test_.
3. Download the _key-file_ and the _chef-repo_ in your local machine.

    You can test the cookbooks with this tools:

    $ cd chef-repo/cookbooks/nginx/
    $ chef exec rspec

for _foodcritic_ validation:

    $ cd chef-repo/
    $ foodcritic -B cookbooks/

### AWS CONFIGURATION

1. Log into the AWS, and search the click on **EC2** option. Then the **EC2** dashboard will appears.
2. Under _Network & Security_ click the **KEY PAIRS** option.Then the dashboard will appears.
3. Click on **Create Key Pair** and then set the name with **earned**.
4. Download the keypair and reserve it.

## GENERAL CONFIGURATION

To configure the hole project in your local machine, you must follow the next instructions:
1. Create a folder with the name of the project.
2. Place inside the folder the _chef-repo_ folder.
3. Inside _chef-repo_ generate a new cookbook called _nginx-server_ and replace the hole content
   with the cookbook recipe: _default.rb_, and the `default_spec.rb` of the pull request.
4. Inside of the main folder Place the _ec2 key pair_ called **earned.pem**, and the terraform file called
   **main.tf**   

### Terraform 

To run the the project you must follow the next instructions:
1. Install terraform in your local machine, and inside the project you must type the _terraform init_ command.
2. Place the AWS **access_key** and the **secret_key** in the top of the file _main.tf_
3. Check the terraform plan with `terraform plan` command, to ensure that all works fine.
4. Run the `terraform apply` command, to deploy our project. When the deploy is done, there a log
   with the load balancer url value called _LOAD_BALANCER_URL_, you can use this domain name, to 
   ensure that the deploy was successful.
5. To revert the deploy you can type the `terraform destroy` command, to perform this action.

