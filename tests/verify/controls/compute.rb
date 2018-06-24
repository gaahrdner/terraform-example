# encoding: utf-8
# copyright: 2018, The Authors

title 'verify compute resources'

content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

name = params['environment_name']['value']
ip = params['webserver_ip']['value']
vpc_id = params['vpc_id']['value']

describe aws_ec2_instance(name: name) do
  it { should exist }
  it { should be_running }
  its('instance_type') { should eq 't2.micro' }
  its('tags') { should include(key: 'Name', value: name)}
end

describe aws_security_group(group_name: name) do
  it { should exist }
  it { should allow_in(port: 22, ipv4_range: '0.0.0.0/0') }
  it { should allow_in(port: 80, ipv4_range: '0.0.0.0/0') }
  its('vpc_id') { should cmp vpc_id }
end
