# Accessing the Cloud services

## Google Cloud

We use Google Cloud to store the state.

If you don't rely on the Application Default Credentials, you need to gain GCS access externally with statically configured `GOOGLE_CREDENTIALS` or a dynamically obtained `GOOGLE_OAUTH_ACCESS_TOKEN` - see the source file at https://github.com/gruntwork-io/terragrunt/blob/main/remote/remote_state_gcs.go, at the time of writing Terragrunt cannot support a custom `GOOGLE_APPLICATION_CREDENTIALS` location.

So, alternatively you can:

### Use access tokens

1. Create a `ServiceAccount` named `terragrunt` (`terragrunt@kube-on-the-cheap.iam.gserviceaccount.com`)
2. Grant roles `Service Account Token Creator` to your IAM entity user and the `ServiceAccount`
3. at every session generate an access token with `export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token --impersonate-service-account terragrunt@kube-on-the-cheap.iam.gserviceaccount.com)`

### Create Application Default Credentials

`GOOGLE_APPLICATION_CREDENTIALS` is the path to a json file with the credentials. According to https://cloud.google.com/docs/authentication/application-default-credentials essentially translates to `gcloud auth application-default login` to create a default `~/.config/gcloud/application_default_credentials.json`.
For more info, see https://cloud.google.com/docs/authentication/gcloud#gcloud-credentials.

For billing access, see [this doc page](https://cloud.google.com/docs/quotas/set-quota-project#set-project-variable). TL;DR make sure that if you use `ADC` you are setting the quota:

```shell
gcloud auth application-default set-quota-project "kube-on-the-cheap"
```

and your user has the `roles/serviceusage.serviceUsageAdmin` role (from the Console, `Service Usage Admin`).

## Oracle Cloud

Oracle Cloud is used for the Compute and Storage resources.

To gain access, you don't need to have `oci-cli` installed, but you do need a `~/.oci/config` file set up. This is due to the fact that (always at the time of writing) the Terraform provider cannot set a custom config file location. To properly blame the Oracle Cloud SDK, see here https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm.

## DigitalOcean

You'll need:
* a token for the TF Provider access to DO's APIs

  1. Go to https://cloud.digitalocean.com/account/api/tokens and create a `Full access` token for your CLI; give it a 30 days expiry window and a meaningful name such as "*doctl cli*".
  2. Invoke then `doctl auth init` and paste the value there. Done.

* a second token used by the external DNS operator to control the domain records

  1. Go to https://cloud.digitalocean.com/account/api/tokens and create a new token with Custom Scopes, select the CRUD operations in the "domain" scope. Give it a meaningful name like "*externaldns*" and a 1y expiry time.
  2. Create a YAML file named `do_tokens.sops.yaml` and use the token as value for a key `externaldns`. Do yourself a favor and add scopes and expiry date in the comments, other than setting it as the variable value for expiry. Encrypt it with SOPS, and make sure comments are encrypted as well. Done.
