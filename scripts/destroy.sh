# !/bin/bash

workspace=$1

if [ "$workspace" == "master" ]; then
    echo "Will not delete a master deployment"
    exit 1
fi

terraform init || exit 1
terraform workspace select $workspace || terraform workspace new $workspace
terraform destroy --auto-approve
terraform workspace select default
terraform workspace delete $workspace
