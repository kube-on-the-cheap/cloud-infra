#!/bin/bash

# Update the instance config to enable the Bastion plugin
dnf install --assumeyes python36-oci-cli
echo '{
  "areAllPluginsDisabled": false,
  "isManagementDisabled": false,
  "isMonitoringDisabled": false,
  "pluginsConfig": [
    {
      "desiredState": "ENABLED",
      "name": "Bastion"
    }
  ]
}' > ./agent_config.json
export OCI_CLI_AUTH=instance_principal
oci compute instance update --instance-id "$(oci-instanceid)" --agent-config file://./agent_config.json --force

# Enable persistent journal logging
mkdir -p /var/log/journal

# Expand the disk
growpart /dev/oracleoci/oraclevda 3
pvresize /dev/oracleoci/oraclevda3
lvextend -l +100%FREE /dev/ocivolume/root
xfs_growfs /

# Continue with the OKE provisioning
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
