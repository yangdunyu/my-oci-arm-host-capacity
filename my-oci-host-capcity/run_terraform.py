import subprocess
import time
import sys
import os
import urllib.request
import zipfile
import platform
import logging

# Configure logging with UTF-8 encoding
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', handlers=[
    logging.FileHandler("deployment.log", encoding='utf-8'),
    logging.StreamHandler(sys.stdout)
])

# Set the PYTHONIOENCODING environment variable
os.environ['PYTHONIOENCODING'] = 'utf-8'

def run_command(command):
    """Run a command and return its output."""
    try:
        result = subprocess.run(command, capture_output=True, text=True, shell=True, encoding='utf-8', errors='replace')
        return result.stdout, result.stderr, result.returncode
    except Exception as e:
        logging.error(f"Error executing command: {e}")
        sys.exit(1)

def download_and_install_terraform_windows():
    """Download and install Terraform if not already installed."""
    terraform_url = "https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_windows_amd64.zip"
    terraform_zip = "terraform.zip"
    install_dir = os.path.dirname(os.path.abspath(__file__))

    logging.info("Windows system, Terraform not installed, downloading...")
    urllib.request.urlretrieve(terraform_url, terraform_zip)
    logging.info("Download complete, extracting...")

    with zipfile.ZipFile(terraform_zip, 'r') as zip_ref:
        zip_ref.extractall(install_dir)

    os.remove(terraform_zip)
    logging.info("Terraform installation complete.")

def install_terraform_ubuntu():
    """Install Terraform using apt on Ubuntu."""
    logging.info("Ubuntu system, Terraform not installed, installing using apt...")
    run_command("wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg")
    run_command('echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list')
    run_command("sudo apt update && sudo apt install -y terraform")
    logging.info("Terraform installation complete.")

def main():
    logging.info("===== Oracle Cloud Infrastructure ARM Instance Auto Deployment Script =====")
    logging.info("Checking environment...")
    
    # Change to the directory where the Terraform configuration files are located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    logging.info(f"Working directory: {script_dir}")
    os.chdir(script_dir)

    # Check the operating system and install Terraform
    system = platform.system()
    if system == "Windows":
        stdout, stderr, returncode = run_command("terraform.exe version")
        logging.info(stdout)
        logging.error(stderr)
        if "Terraform v" not in stdout:
            download_and_install_terraform_windows()
    elif system == "Linux":
        # Check if it is Ubuntu
        stdout, stderr, returncode = run_command("terraform version")
        if "Terraform v" not in stdout:
            install_terraform_ubuntu()

    # Check if Terraform is correctly installed
    stdout, stderr, returncode = run_command("terraform version")
    if "Terraform v" in stdout:
        logging.info(f"✓ Terraform is correctly installed: {stdout.splitlines()[0]}")
    else:
        logging.error(f"✗ Terraform installation error, please check the output: {stderr}")

    # Initialize Terraform
    logging.info("\nInitializing Terraform...")
    stdout, stderr, returncode = run_command("terraform init")
    logging.info(stdout)
    if returncode != 0:
        logging.error(f"✗ Terraform initialization failed, exit code: {returncode}")
        sys.exit(1)
    logging.info("✓ Terraform initialization successful")

    # Execute Terraform apply and retry
    retry_count = 0
    success = False
    initial_wait = 1  # Initial wait time (seconds)
    max_wait = 60  # Maximum wait time (seconds)
    backoff_factor = 1.1  # Backoff factor

    logging.info("\nStarting resource creation...")
    while not success:
        retry_count += 1
        logging.info(f"Attempt {retry_count} for Terraform apply, current backoff time: {initial_wait} seconds")

        stdout, stderr, returncode = run_command("terraform apply -auto-approve")
        # logging.info(stdout)

        if returncode == 0:
            success = True
            logging.info(stdout)
            logging.info("\n✓ Resource creation successful!")
            initial_wait = 1  # Reset wait time
        else:
            if "Error: 500-InternalError" in stdout or "capacity" in stdout or "Out of host capacity" in stdout:
                logging.warning("\n⚠ Detected insufficient resource capacity, retrying after backoff time...")
                time.sleep(initial_wait)
            elif "429" in stdout or "Too Many Requests" in stdout:
                logging.error(stderr)
                logging.warning("\n⚠ Detected request limit, retrying after 120 seconds plus backoff time...")
                time.sleep(120 + initial_wait)
                initial_wait = min(max_wait, initial_wait * backoff_factor)  # Increase wait time
            else:
                logging.error(stderr)
                logging.error("\n✗ Terraform apply failed, unknown error, terminating script")
                sys.exit(1)

    # Display output information
    logging.info("\nRetrieving instance information...")
    stdout, stderr, returncode = run_command("terraform output")
    logging.info(stdout)

    logging.info("\n===== Deployment Complete =====")
    logging.info("You can now connect to the newly created instance using SSH")

if __name__ == "__main__":
    main() 