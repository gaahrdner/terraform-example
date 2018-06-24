validate:
	terraform validate

init:
	terraform init

apply:
	terraform apply -var-file=terraform.tfvars.sample

test:
	terraform output --json > tests/verify/files/terraform.json
	inspec exec tests/verify -t aws://