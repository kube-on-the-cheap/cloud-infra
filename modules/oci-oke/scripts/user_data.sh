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

# Enable persistent journal logging with size limits
mkdir -p {/var/log/journal,/etc/systemd/journald.conf.d}
cat > /etc/systemd/journald.conf.d/10-disk-usage.conf <<EOF
[Journal]
SystemMaxUse=3G
SystemKeepFree=2G
MaxRetentionSec=7day
MaxFileSec=1day
EOF
systemctl restart systemd-journald

# LVM thin provisioning
echo "dm_thin_pool" >> /etc/modules-load.d/lvm-thin.conf
modprobe dm_thin_pool

# Expand the disk partition and PV
growpart /dev/oracleoci/oraclevda 3
pvresize /dev/oracleoci/oraclevda3

# Extend root to 45GB total, leaving remaining space for OpenEBS LVM PVs
lvextend -L 45G /dev/ocivolume/root
xfs_growfs /

# Continue with the OKE provisioning
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
