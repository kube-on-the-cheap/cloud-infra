# Email

This module configures email delivery for Oracle Cloud Infrastructure.

It builds a domain for delivery, creates the necessary user and permissions to enable email submission using APIs and SMTP and stores credentials in Oracle Vault.

```bash
SMTP_SERVER=$(terragrunt output -json | jq -r '.email_submission_endpoints.value.smtp')
SMTP_USERNAME=$(terragrunt output -json | jq -r '.smtp_credentials.value.mailer.username')
SMTP_PASSWORD=$(terragrunt output -json | jq -r '.smtp_credentials.value.mailer.password')

AUTHORIZED_SENDER="do-not-reply@oci.cloud.blacksd.tech"

nix run nixpkgs#swaks -- --pipeline -tls --to 'valid-recipient@gmail.com' \
--server ${SMTP_SERVER} --port 587 \
--from ${AUTHORIZED_SENDER} \
--auth-user ${SMTP_USERNAME} \
--auth-password ${SMTP_PASSWORD} \
--header 'Subject: Test Email from Oracle Cloud' \
--body 'Sample text'
```
