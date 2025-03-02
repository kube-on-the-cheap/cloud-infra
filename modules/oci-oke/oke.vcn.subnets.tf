locals {
  # nix run nixpkgs#ipcalc -- 172.16.0.0/16 --split 18
  cidr_blocks = {
    # cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 0)  -->  172.16.0.0/18
    regional = {
      # ❯ nix run nixpkgs#ipcalc -- 172.16.0.0/18 --split 20
      # [Split networks]
      # Network:        172.16.0.0/20
      # Network:        172.16.16.0/20
      # Network:        172.16.32.0/20
      # Network:        172.16.48.0/20

      # Total:          4
      # Hosts/Net:      4094
      control_plane = cidrsubnet(cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 0), 2, 0) # 172.16.0.0/20
      pods          = cidrsubnet(cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 0), 2, 1) # 172.16.16.0/20
    }

    # cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 1)  -->  172.16.64.0/18
    ad = {
      # ❯ nix run nixpkgs#ipcalc -- 172.16.64.0/18 --split 20
      # [Split networks]
      # Network:        172.16.64.0/20
      # Network:        172.16.80.0/20
      # Network:        172.16.96.0/20
      # Network:        172.16.112.0/20

      # Total:          4
      # Hosts/Net:      4094
      load_balancers = cidrsubnet(cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 1), 2, 0) # 172.16.64.0/20
      nodes          = cidrsubnet(cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 1), 2, 1) # 172.16.80.0/20
    }

    # INFO: reserved for future use cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 2)  -->  172.16.128.0/18
    # INFO: reserved for future use cidrsubnet(one(oci_core_vcn.oke.cidr_blocks), 2, 3)  -->  172.16.192.0/18
  }
}

# -- Regional subnets

resource "oci_core_subnet" "regional_control_plane" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id                     = oci_core_vcn.oke.id
  cidr_block                 = local.cidr_blocks.regional.control_plane
  display_name               = format("%s-%s-regional-control-plane", oci_identity_compartment.oke.name, var.region)
  prohibit_public_ip_on_vnic = true # Makes it private
  security_list_ids = [
    oci_core_default_security_list.vcn_oke.id,
  ]
  lifecycle {
    create_before_destroy = false
  }
}

resource "oci_core_subnet" "regional_pods" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id                     = oci_core_vcn.oke.id
  cidr_block                 = local.cidr_blocks.regional.pods
  display_name               = format("%s-%s-regional-pods", oci_identity_compartment.oke.name, var.region)
  prohibit_public_ip_on_vnic = true # Makes it private
  security_list_ids = [
    oci_core_default_security_list.vcn_oke.id,
  ]
}

# -- AD-specific subnets

resource "oci_core_subnet" "ad_lbs" {
  compartment_id = oci_identity_compartment.oke.id

  for_each = toset(keys(local.availability_domains))

  vcn_id              = oci_core_vcn.oke.id
  availability_domain = each.key
  cidr_block          = cidrsubnet(local.cidr_blocks.ad.load_balancers, 2, index(keys(local.availability_domains), each.key))
  display_name        = format("%s-%s-lb", oci_identity_compartment.oke.name, lower(split(":", each.key)[1]))
  security_list_ids = [
    oci_core_vcn.oke.default_security_list_id,
    oci_core_security_list.additional_lb.id
  ]
  route_table_id = oci_core_route_table.oke_public_lb_route_table.id
}

resource "oci_core_subnet" "ad_nodes" {
  compartment_id = oci_identity_compartment.oke.id

  for_each = toset(keys(local.availability_domains))

  vcn_id                     = oci_core_vcn.oke.id
  availability_domain        = each.key
  cidr_block                 = cidrsubnet(local.cidr_blocks.ad.nodes, 2, index(keys(local.availability_domains), each.key))
  display_name               = format("%s-%s-nodes", oci_identity_compartment.oke.name, lower(split(":", each.key)[1]))
  prohibit_public_ip_on_vnic = true # Makes it private
  security_list_ids = [
    oci_core_vcn.oke.default_security_list_id,
  ]
}
