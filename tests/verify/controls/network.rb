# encoding: utf-8
# copyright: 2018, The Authors

title 'verify network resources'

content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

name = params['environment_name']['value']
vpc_id = params['vpc_id']['value']

describe aws_vpc(vpc_id) do
  it { should exist }
  its('cidr_block') { should cmp '10.0.0.0/16' }
end
