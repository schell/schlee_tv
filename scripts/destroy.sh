# !/bin/bash

workspace=$1

terraform init
terraform workspace select $workspace || terraform workspace new $workspace
terraform destroy --auto-approve -var="is_teardown=true"
terraform workspace select default
terraform workspace delete $workspace
