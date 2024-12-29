$environments = @("lab", "dev", "prod")
foreach ($env in $environments) {
    terraform workspace select $env
    terraform destroy -auto-approve
}