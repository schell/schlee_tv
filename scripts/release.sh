# !/bin/bash

workspace=$1

terraform init
terraform workspace select $workspace || terraform workspace new $workspace
terraform apply --auto-approve
