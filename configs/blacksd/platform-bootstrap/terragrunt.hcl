# NOTE: open a bastion session to the control plane before running this
terraform {
  source = "../../..//modules/platform-bootstrap/"

  extra_arguments "use_https_proxy" {
    commands = ["plan", "apply", "refresh", "import"]
    env_vars = {
      HTTPS_PROXY = "socks5://127.0.0.1:8000"
    }
  }
}

# TODO: not including an explicit dependency here because we don't have output values that
#       are tracked as part of the dependency.

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

inputs = {
  flux_version = "2.5.x"
  sync = {
    repo = "https://github.com/kube-on-the-cheap/platform"
    path = "clusters/freeloader"
  }
}
