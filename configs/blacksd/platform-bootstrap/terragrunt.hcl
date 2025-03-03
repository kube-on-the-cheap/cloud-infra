terraform {
  source = "../../..//modules/platform-bootstrap/"

  # INFO: this does work, but then we need to manage the background process, and it's not practical; it's
  #       easier just to check we have a proxy running and abort execution if we don't
  #
  after_hook "run_proxy" {
    commands = ["terragrunt-read-config"]
    execute  = ["${get_parent_terragrunt_dir()}/../bastion-sessions/control-plane/open_bastion_proxy_session.sh"]
  }

  after_hook "check_proxy" {
    commands = ["terragrunt-read-config"]
    execute  = ["nc", "-v", "-z", "127.0.0.1", "8000"]
  }

  extra_arguments "use_https_proxy" {
    commands = ["plan", "apply", "refresh", "import"]
    env_vars = {
      KUBE_PROXY_URL = "socks5://127.0.0.1:8000"
    }
  }
}

# INFO: this dependency is here for tracking, but it's kinda moot since we rely on the proxy
#       script to have a successful run
#
dependencies {
  paths = ["../oci-bastion-sessions/oke-control-plane"]
}

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
