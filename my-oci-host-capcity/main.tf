terraform {
  required_providers {
    oci = {
      source  = "oracle/oci" 
      version = ">= 4.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
  region              = var.region
}

resource "oci_core_instance" "arm_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.tenancy_ocid # each tenancy has a default "root compartment", free tier users generally only use the root compartment, the ID of the root compartment is the same as the tenancy OCID
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.ocups
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id = var.subnet_id
    assign_public_ip = true
  }

  source_details {
    source_type             = var.instance_source_type
    source_id               = var.source_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }
}
