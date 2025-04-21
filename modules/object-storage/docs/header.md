# Secrets

This module is about creating a secrets deployment module for resources that

1. Don't have a proper Terraform provider; this would be the preferred way to manage their lifecycle, but if it doesn't exist (and my lab use case isn't big enough to warrant a contribution) it's just best to create the secret manually, encrypt it here and ship it to Vault
2. Don't have any connection to existing other resources from the same scope; it's fine to have a secret shipped to Vault in a module that does other things for the same part of the infra, but if there is no module, it's just best to collect all single-purpose secrets in a single place

See:
* the lack of support for GitHub Apps, [issue ref.](https://github.com/integrations/terraform-provider-github/issues/509)
