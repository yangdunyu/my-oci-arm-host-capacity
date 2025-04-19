variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint for the API key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
}

variable "region" {
  description = "The OCI region where resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain where the instance will be created"
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created. The OCID of the Root Compartment is your Tenancy OCID."
  type        = string
}

variable "ocups" {
  description = "The number of OCPUs for the instance"
  type        = number
}

variable "memory_in_gbs" {
  description = "The amount of memory in GBs for the instance"
  type        = number
}

variable "subnet_id" {
  description = "The OCID of the subnet for the instance's VNIC"
  type        = string
}

variable "source_id" {
  description = "The OCID of the image to use for the instance"
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GBs. Minimum 50 GB."
  type        = number
  default     = 50
}

variable "ssh_authorized_keys" {
  description = "The path to the public SSH key file to authorize access to the instance"
  type        = string
}

variable "instance_shape" {
  description = "The shape of the instance (e.g., VM.Standard.A1.Flex)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_source_type" {
  description = "The source type for the instance (image or bootVolume)"
  type        = string
  default     = "image"
}