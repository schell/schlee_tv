# !/bin/bash

workspace=$1

terraform init || exit 1
terraform workspace select $workspace || terraform workspace new $workspace
terraform apply --auto-approve
