# Create the VCN
resource "oci_core_virtual_network" "ctf_vcn" {
  compartment_id = var.compartment_id
  display_name   = "ctf-vcn"
  cidr_block     = "10.0.0.0/16"
}

# Create the public subnet
resource "oci_core_subnet" "ctf_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-subnet"
  cidr_block     = "10.0.0.0/24"
  route_table_id = oci_core_route_table.ctf_public_route_table.id
  security_list_ids = [
    oci_core_security_list.ctf_public_security_list.id
  ]
  # availability_domain = var.availability_domain # regional if omitted
  prohibit_public_ip_on_vnic = false # Allows public IP assignment
}

# Create the internet gateway
resource "oci_core_internet_gateway" "ctf_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-internet-gateway"
}

# Create the route table for public subnet
resource "oci_core_route_table" "ctf_public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-route-table"
  
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id  = oci_core_internet_gateway.ctf_internet_gateway.id
  }
}

# Security List (Firewall Rules)
resource "oci_core_security_list" "ctf_public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-security-list"
  
  ingress_security_rules {
    protocol    = "6"   # TCP
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "22" # SSH
        max = "22"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "80" # HTTP
        max = "80"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "8000" # CTFd port
        max = "8000"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "443" # HTTPS
        max = "443"
    }
  }
  
  ingress_security_rules {
    protocol              = "6" 
    source                = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "12345" # netcat ports
        max = "12355"
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"  # Allow all outbound traffic
  }
}

resource "oci_core_instance" "ctfd_instance" {
    compartment_id      = var.compartment_id
    availability_domain = var.availability_domain
    shape               = var.vm_shape
    display_name        = "ctfd-instance"

    shape_config {
        ocpus = var.ocpus
        memory_in_gbs = var.memory_in_gbs
    }

    source_details {
        source_type = "image"
        source_id = var.image_id
    }

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }
    
    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key)
        user_data           = filebase64("scripts/cloud-init.sh")  # Script for setting up the VM
    }
}

/*
resource "oci_core_instance" "challenges_instance" {
    compartment_id      = var.compartment_id
    availability_domain = var.availability_domain
    shape               = var.vm_shape
    display_name        = "challenges-instance"

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }

    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key)
        user_data           = filebase64("scripts/cloud-init-k8s.sh")  # Script for setting up the VM
    }
}
*/