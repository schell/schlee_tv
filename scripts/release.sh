# !/bin/bash

workspace=$1

#terraform init || exit 1
#terraform workspace select $workspace || terraform workspace new $workspace
#terraform apply --auto-approve

if [ "${workspace}" == "master" ]
then
    domain_name="schlee.tv"
else
    domain_name="${workspace}.schlee.tv"
fi

echo "Deploying to ${domain_name}"

aws s3 sync build/site s3://${local.domain_name}/
