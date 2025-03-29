# Tailscale

This module adds a couple resources used in conjunction with the Tailscale K8s operator.

Unfortunately the Tailscale provider is pretty slim in functionalities offered, so a bunch of manual activities are still required. You'll find a more in-depth explanation [in the docs](https://tailscale.com/kb/1236/kubernetes-operator) but in a nutshell you need to log in to the web console to:

- choose a fancy name for the tailnet
- enable HTTPS
- create an OAuth client with the `Devices Core` and `Auth Keys` write scopes; be careful that the client needs to be scoped to the correct `k8s-operator` tag, which is maintained as part of the ACL for the tailnet.
