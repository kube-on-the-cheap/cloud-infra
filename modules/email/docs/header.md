# Email

This module configures email delivery for Oracle Cloud Infrastructure.

It builds a domain for delivery, creates the necessary user and permissions to enable email submission using APIs and SMTP and stores credentials in Oracle Vault.

## SMTP test

```bash
SMTP_SERVER=$(terragrunt output -json | jq -r '.email_submission_endpoints.value.smtp.endpoint')
SMTP_USERNAME=$(terragrunt output -json | jq -r '.email_submission_credentials_user_sender.value.username')
SMTP_PASSWORD=$(terragrunt output -json | jq -r '.email_submission_credentials_user_sender.value.password')

AUTHORIZED_SENDER="<authorized_sender>@mail.cloud.blacksd.tech"

nix run nixpkgs#swaks -- --pipeline -tls --to '<valid_recipient>@gmail.com' \
--server ${SMTP_SERVER} --port 587 \
--from ${AUTHORIZED_SENDER} \
--auth-user ${SMTP_USERNAME} \
--auth-password ${SMTP_PASSWORD} \
--header 'Subject: Test Email from Oracle Cloud' \
--body 'This is a test mail from Oracle Cloud.'
```

## API test

TODO: but will probably use [this API call](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/api/#/en/emaildeliverysubmission/20220926/EmailSubmittedResponse/SubmitEmail)
