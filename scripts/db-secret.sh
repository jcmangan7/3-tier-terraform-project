aws secretsmanager create-secret \
    --name rdsmysql3 \
    --secret-string '{""}' \
    --description "RDS MySQL password for Terraform"

# Verify the Secret:
aws secretsmanager get-secret-value --secret-id rdsmysql3