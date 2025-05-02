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
