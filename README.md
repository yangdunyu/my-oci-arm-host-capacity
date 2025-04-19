# OCI ARM Host Capacity Provisioning

This repository contains Terraform configurations and scripts to automate the provisioning of ARM-based instances on Oracle Cloud Infrastructure (OCI).

## Motivation

Oracle Cloud Infrastructure (OCI) offers Always Free ARM instances, but these resources are extremely scarce and difficult to secure. This project was created to solve this problem by:

- Automatically monitoring for available ARM capacity on OCI
- Instantly attempting to provision when resources become available
- Implementing intelligent retry mechanisms when facing "capacity not available" errors
- Reducing manual effort in repeatedly checking for and claiming free resources

With this tool, you can let the script run in the background and automatically provision an ARM instance as soon as capacity becomes available, rather than manually checking and facing disappointment.

## Prerequisites

- An Oracle Cloud Infrastructure account
- Ubuntu Instance (recommended)

## Parameter Setup (.env file)

`.env` file with the following parameters:

```
TENANCY_OCID=your_tenancy_ocid
USER_OCID=your_user_ocid
FINGERPRINT=your_api_key_fingerprint
PRIVATE_KEY_PATH=/path/to/your/private_key.pem
REGION=your_oci_region
COMPARTMENT_ID=your_compartment_id
AVAILABILITY_DOMAIN=your_availability_domain
SHAPE=your_instance_shape
OCPUS=number_of_ocpus
MEMORY_IN_GBS=memory_in_gb
IMAGE_ID=your_image_id
SUBNET_ID=your_subnet_id
SSH_PUBLIC_KEY="your_ssh_public_key"
```

### How to obtain these parameters:

1. **TENANCY_OCID**: 
   - Go to OCI Console → Profile menu (top-right) → Tenancy
   - Copy the OCID displayed on the page

2. **USER_OCID**:
   - Go to OCI Console → Profile menu → User Settings
   - Copy the OCID displayed on the page

3. **FINGERPRINT & PRIVATE_KEY_PATH**:
   - You need to generate an API key for OCI
   - Go to OCI Console → Profile menu → User Settings → API Keys → Add API Key
   - Generate a new key pair or upload an existing one
   - Copy the fingerprint after adding the key
   - Save the private key to your machine and specify the full path

4. **REGION**:
   - Use the region identifier (e.g., `us-phoenix-1`, `ap-tokyo-1`)
   - Find your region code at the top of the OCI Console

5. **COMPARTMENT_ID**:
   - Go to OCI Console → Identity → Compartments
   - Select your compartment and copy the OCID

6. **AVAILABILITY_DOMAIN**:
   - Go to OCI Console → Compute → Instances → Create Instance
   - Note the available domains in the dropdown menu
   - Format: "xxxx:US-ASHBURN-AD-1" (replace with your region)

7. **SHAPE**:
   - For free ARM instances, use: `VM.Standard.A1.Flex`

8. **OCPUS & MEMORY_IN_GBS**:
   - For free tier limits, use: OCPUS=4 and MEMORY_IN_GBS=24

9. **IMAGE_ID**:
   - Go to OCI Console → Compute → Custom Images
   - Or use the OCI CLI: `oci compute image list --compartment-id $COMPARTMENT_ID --operating-system "Canonical Ubuntu" --shape VM.Standard.A1.Flex`
   - Copy the OCID of your preferred image

10. **SUBNET_ID**:
    - Go to OCI Console → Networking → Virtual Cloud Networks → [Your VCN] → Subnets
    - Copy the OCID of the subnet where you want to deploy

11. **SSH_PUBLIC_KEY**:
    - The content of your public SSH key
    - Generate one with: `ssh-keygen -t rsa -b 2048`
    - Copy the content of `~/.ssh/id_rsa.pub`

## Running in Ubuntu

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/my-oci-arm-host-capacity.git
   cd my-oci-arm-host-capacity
   ```

2. **Create and configure the .env file**:
   ```bash
   nano .env
   # Add all the parameters as described above
   ```

3. **Make the installation script executable**:
   ```bash
   chmod +x install_terraform.sh
   ```

4. **Run the installation script**:
   ```bash
   ./install_terraform.sh
   ```

5. **Let it run**:
   The script will automatically:
   - Install Terraform if not already installed
   - Keep trying to provision ARM instances until successful
   - Handle rate limits and capacity errors with appropriate retry mechanisms

You can keep this running in the background (consider using `screen` or `tmux`) until it successfully provisions your ARM instance.

## Output

Upon successful provisioning, the script will output the public IP address of your newly created ARM instance.

## Troubleshooting

- If you encounter "Too Many Requests" errors, the script will automatically wait and retry.
- For persistent "Out of capacity" errors, the script will continue retrying - this is normal and expected.
- For configuration errors, check OCI console for specifics.

## License

[Your License Here] 