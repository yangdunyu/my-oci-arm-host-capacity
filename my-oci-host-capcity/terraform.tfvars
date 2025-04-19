# --- OCI API Credentials ---
tenancy_ocid        = "ocid1.tenancy.oc1..exampleuniqueID"
user_ocid           = "ocid1.user.oc1..exampleuniqueID"
fingerprint         = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path    = "/path/to/your/private_key.pem"
region              = "us-ashburn-1"

# --- Instance Configuration ---
availability_domain = "Uocm:PHX-AD-1"
subnet_id           = "ocid1.subnet.oc1..exampleuniqueID"
source_id           = "ocid1.image.oc1..exampleuniqueID"
ocups               = 2
memory_in_gbs       = 12 
boot_volume_size_in_gbs = 50
ssh_authorized_keys = "ssh-ed25519 AAAAC3N***o2U user@example.com"
