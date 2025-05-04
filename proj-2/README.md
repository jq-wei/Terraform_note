1. create vpc
2. create internet gateway
3. create custom route table
4. create a subnet
5. associate subnet with route table
6. create security group to allow port 22,80, 443
7. create a network interface with an ip in the subnet that was created in step 4
8. assign an elastic IP to the network interface created in step 7
9. create ubuntu server and install/enable apache2

Listing suitable EC2:
`aws ec2 describe-images --filters "Name=virtualization-type,Values=hvm" "Name=architecture,Values=x86_64" --query 'Images[].[ImageId,Name]' --output table`


# some useful terraform cmd

1. `terraform state list` show all the stated resources
2. `terraform state show aws_eip.one` show the details of a specfic resource, i.e., aws_eip.one
3. `terraform refresh`
4. `terraform destroy/apply -target aws_instance.web-server-instance` to destroy or create a specific resource
5. `terraform apply -var-file example.tfvars` to look for var value in a file named as example.tfvars
