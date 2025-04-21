# OCI ARM Host Capacity Provisioning

This repository contains Terraform configurations and scripts to automate the provisioning of ARM-based instances on Oracle Cloud Infrastructure (OCI).

## Motivation

Oracle Cloud Infrastructure (OCI) offers Always Free ARM architecture instances, but these resources are extremely scarce and difficult to secure for free tier users. This project was created to solve this problem by:

- Automatically monitoring for available ARM capacity on OCI
- Implementing intelligent retry mechanisms when facing "out of capacity" errors
- Reducing manual effort in repeatedly checking for and claiming free ARM resources

With this tool, you can let the script run in the background and automatically provision an ARM instance as soon as capacity in your region becomes available, rather than manually checking and facing disappointment.

## Tech Stack

<img src="https://www.terraform.io/img/logo-terraform-main.svg" alt="Terraform Logo" width="150"/>

This project uses Terraform, HashiCorp's infrastructure as code (IaC) tool that allows the definition of resources and infrastructure in human-readable configuration files. Terraform enables the safe building, changing, and versioning of cloud infrastructure. It automates the provisioning process by codifying cloud APIs into declarative configuration files, allowing for consistent deployment and easy tracking of infrastructure changes.


## How to Use

The overall process is simple and consists of just three steps:

1. Clone this repository to your Ubuntu machine:
   ```bash
   git clone https://github.com/yourusername/my-oci-arm-host-capacity.git
   cd my-oci-host-capcity
   ```

2. Configure the `terraform.tfvars` file with your OCI credentials and instance settings (detailed below)

3. Enter the project folder and Run the provisioning script:
   ```bash
   bash run_terraform.sh
   ```

## Configuration Guide

The most important part is configuring the variables in `terraform.tfvars`. Follow these steps carefully to obtain all required information.

> **Important**: Never commit or share your `terraform.tfvars` file as it contains sensitive credentials.

### Step 1: Generate OCI API Keys

From the process below, you'll obtain these values for your `.tfvars` file:
- `tenancy_ocid`: Your tenancy OCID 
- `user_ocid`: Your user OCID
- `fingerprint`: The API key fingerprint
- `private_key_path`: Path where you saved your private key (e.g., `/home/user/.oci/oci_api_key.pem`)
- `region`: Your preferred OCI region (e.g., `ap-tokyo-1`)

1. Log in to the [OCI Console](https://cloud.oracle.com)

2.After logging in to OCI Console, click profile icon and then "User Settings"

[User Settings.jpg]

3.Go to Resources -> API keys, click "Add API Key" button

[Add API Key.jpg]

4.Make sure "Generate API Key Pair" radio button is selected, click "Download Private Key" and then "Add".

[Download Private Key.jpg]

5.Copy the contents from textarea and extract corresponding value and save  to .tfvars file with same key name. save private key file(*.pem file) to the directory of the host that you want execute the script via SFTP or other method. I put  *.pem file in newly created directory /home/ubuntu/.oci

### Step 2: Gather Instance Configuration Details

Go through the instance creation process in the OCI web console (without actually creating it) to gather these parameters:

- `subnet_id`: OCID of the subnet where your instance will be created (found in Networking → Virtual Cloud Networks → [Your VCN] → Subnets)
- `source_id`: OCID of the OS image (found in Compute → Instances → Create Instance → Image)
- `ocups`: Number of OCPUs for your ARM instance (typically 2-4 for free tier)
- `memory_in_gbs`: RAM amount in GB (typically 12-24 for free tier)
- `boot_volume_size_in_gbs`: Boot volume size in GB (minimum 50)
- `ssh_authorized_keys`: Your public SSH key content for accessing the instance,reminder its the content instead of the path to .pub file

You must start instance creation process from the OCI Console in the browser (Menu -> Compute -> Instances -> Create Instance)

Change image and shape. For Always free ARM - make sure that "Always Free Eligible" availabilityDomain label is there:

[Changing image and shape.jpg]

ARMs can be created anywhere within your home region.

Adjust Networking section, set "Do not assign a public IPv4 address" checkbox. If you don't have existing VNIC/subnet, please create a instance with subnet before doing everything.

[Networking.jpg]

"Add SSH keys" section does not matter for us right now. Before clicking "Create"…

[Add SSH Keys.jpg]

…open browser's dev tools -> network tab. Click "Create" and wait a bit most probably you'll get "Out of capacity" error. Now find /instances API call (red one)…

[Dev Tools.jpg]

…and right click on it -> copy as curl. Paste the clipboard contents in any text editor and review the data-binary parameter. Find subnet_id, image_id(as source_id) respectively.

ssh_authorized_keys (SSH access)
In order to have secure shell (SSH) access to the instance you need to have a keypair, besically 2 files:

~/.ssh/id_rsa
~/.ssh/id_rsa.pub
Second one (public key) contents (string) should be provided to a command below. The are plenty of tutorials on how to generate them (if you don't have them yet), we won't cover this part here.

cat ~/.ssh/id_rsa.pub
Output should be similar to

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwZVQa+F41Jrb4X+p9gFMrrcAqh9ks8ATrcGRitK+R/ github.com@dunyu.com
Change `ssh_authorized_keys` inside double quotes - paste the contents above (or you won't be able to login into the newly created instance). NiuBi! No new lines allowed!

`ocpus` and `memory_in_gbs` are set 4 and 24 by default. Of course, you can safely adjust them. Possible values are 1/6, 2/12, 3/18 and 4/24, respectively. Please notice that "Oracle Linux Cloud Developer" image can be created with at least 8GB of RAM (memory_in_gbs).

If for some reason your home region is running out of Always free ARM (total 4 OPCU + 24GB RAM), script will report error and exit







