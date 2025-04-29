steps to run

1. `terraform init`
2.  optional `terraform plan`. Similar to git diff which shows the exact line-by-line changes before committing
`terraform plan` shows the exact infrastructure changes Terraform will make (create, update, delete resources) before applying them. 
3. `terraform apply`
4. `terraform destroy` will delete all the resoource created by the terraform file.